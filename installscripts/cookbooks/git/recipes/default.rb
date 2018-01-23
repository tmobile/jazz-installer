if node[:platform_family].include?("rhel")
    execute 'gitinstall' do
       command 'yum install git -y'
    end
  end
  if node[:platform_family].include?("debian")
     execute 'update-apt' do
        command 'apt-get update'
     end
     execute 'gitinstall' do
        command 'apt-get install git -y'
     end
  end