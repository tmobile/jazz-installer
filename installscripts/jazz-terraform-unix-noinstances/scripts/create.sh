#!/bin/sh

print_error()
{
    printf "\r${RED}$1${NC}\n" 1>&3 2>&4
}

rm -f ./settings.txt
date
terraform init && terraform apply \
                            --auto-approve \
                            -var "aws_access_key=${AWS_ACCESS_KEY_ID}" \
                            -var "aws_secret_key=${AWS_SECRET_ACCESS_KEY}" \
                            -var "region=${AWS_DEFAULT_REGION}"
if [ $? -gt 0 ]
then
    date
    print_error "$message....Failed"
    print_error "Destroying created AWS resources because of failure"
    terraform destroy --auto-approve
    echo " ======================================================="
    echo " To cleanup Jazz stack and its resources execute ./destroy.sh in this directory."
    realpath ../../
    echo " ======================================================="
    exit
else
    date
    echo " ======================================================="
    echo " The following stack has been created in AWS"
    echo " ________________________________________________"
    terraform state list
    echo " ======================================================="
    echo " Please use the following values for checking out Jazz"
    echo " ________________________________________________"
    cat ./settings.txt
    echo " ======================================================="
    echo " Installation complete! To cleanup Jazz stack and its resources execute ./destroy.sh in this directory."
    realpath ../../
    echo " ======================================================="
    exit
fi
