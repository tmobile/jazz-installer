check_file="/home/ec2-user/jazz-installer/stack_creation.out"

if [ ! -f $check_file ]; then
    echo "No previous stack_creation logs found!"
    echo "Proceeding with new stack deployment..."
else
    for i in {0..30}
    do
        check_date=`date -d "-$i day" +%Y%m%d`
        stack_name="jazz$check_date"
        command=`grep -m 2 -i $stack_name $check_file`
        if [ $? -eq 0 ] ; then
            echo "Found stack_name: $stack_name in $check_file"
            echo "Destroying stack $stack_name...."
            if [ -f "~/jazz-installer/destroy.sh" ]; then
                ~/jazz-installer/destroy.sh all
                else
                echo "Destroy script not found!"
            fi
            exit
        fi
    done
    if [ $? -eq 0 ]; then
        echo "No stacks found in $check_file"
    fi
fi
