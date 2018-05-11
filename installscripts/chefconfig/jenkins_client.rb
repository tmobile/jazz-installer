#root = File.absolute_path(File.dirname(__FILE__))
# Scenario 1 expects cookbook location at ~/cookbooks
# Scenarios 2 & 3 expects cookbook location at /root/cookbooks
cookbook_path [ '~/cookbooks', '/root/cookbooks' ]
