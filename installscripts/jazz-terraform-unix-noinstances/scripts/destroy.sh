#!/bin/bash
date

stack_name=""
currentDir=`pwd`
loopIndx=0

if [ "$1" == "" ]; then
     echo "Please provide Argument [all or frameworkonly]"
     exit 1
fi

echo "parameter::$1"

if [ "$1" != "all" ] && [ "$1" != "frameworkonly" ]; then
     echo "Please provide Argument [all or frameworkonly]"
     exit 1
fi

# Rename any stack_deletion out files if any
for x in $JAZZ_ROOT/stack_de*.out
do
    if [ -f "$x" ]
    then
        mv $x ${x%.out}-old.out
    fi
done

echo " ======================================================="
echo " The following stack has been marked for deletion in AWS"
echo " ________________________________________________"
cd installscripts/jazz-terraform-unix-noinstances
terraform state list

echo " ======================================================="

echo " Destroying of stack initiated!!! "
echo " Execute  'tail -f stack_deletion_X.out' in below directory to see the stack deletion progress (X=1 or 2 or 3)"
echo $currentDir

echo " ======================================================="

# Calling the Delete platform services py script
if [ "$1" == "all" ]; then
    #Deleting the event source handler mapping
    python scripts/DeleteEventSourceMapping.py $stack_name

    #Deleting Platform services
    python scripts/DeleteStackPlatformServices.py $stack_name true

    #Deleting Cloud Front Distributions
    cd $JAZZ_ROOT/installscripts/jazz-terraform-unix-noinstances
    python scripts/DeleteStackCloudFrontDists.py $stack_name true

    echo "Destroy cloudfronts"
    cd $JAZZ_ROOT/installscripts/jazz-terraform-unix-noinstances
    python scripts/DeleteStackCloudFrontDists.py $stack_name false

    while [ $loopIndx -le 2 ];
    do
        ((loopIndx++))
        nohup terraform destroy --force >> ../../stack_deletion_$loopIndx.out &&

        echo "Waiting for terraform to finish updating the logs for 30 secs"
        sleep 30s
        if (grep -q "Error applying plan" ../../stack_deletion_$loopIndx.out); then
            echo "Found error in terraform destroy. In run=" + $loopIndx + ", starting to destroy again"
            terraform state list
        else
            echo "Terraform destroy success"
            break
        fi
    done

    if [ $loopIndx -ge 3 ]; then
        exit 1
    fi

fi

if [ "$1" == "frameworkonly" ]; then
    #Deleting the event source handler mapping
    python scripts/DeleteEventSourceMapping.py $stack_name

    #Deleting Platform services
    python scripts/DeleteStackPlatformServices.py $stack_name false

    #Calling the terraform destroy
    # TODO This is a code smell, if we have correctly declared resource dependencies in our terraform scripts, terraform should destroy everything we created without us having to maintan a list of every resource and pass it to `terraform destroy` like this.
    terraform destroy
    date
    exit 0
fi


cd $JAZZ_ROOT

if (grep -q "Error applying plan" ./stack_deletion_$loopIndx.out) then
    echo "Error occured in destroy, please refer stack_deletion.out and re-run destroy after resolving the issues."
    exit 1
fi

echo "Proceeding to delete Jazz instance."
shopt -s extglob
sudo rm -rf !(*.out)
sudo rm -rf ../Installer.sh ../atlassian-cli*

date
