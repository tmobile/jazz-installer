#
# Cookbook Name:: docker
# Recipe:: default
#
# Copyright (c) 2017 The Authors, All Rights Reserved.
file "/cheftest.txt" do
  content 'This file was created by Chef!'
end