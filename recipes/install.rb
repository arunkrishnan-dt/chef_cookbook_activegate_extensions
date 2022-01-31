#
# Cookbook:: activegate_extensions
# Recipe:: install
#
# Copyright:: 2022, The Authors, All Rights Reserved.

log 'install_log' do
    message "Install - #{node.default['extension']['name']}, #{node.default['extension']['version']}, #{node.default['extension']['os']}"
    level :info
end  

# setting gloabl vars as local vars for convenience
name = "#{node.default['extension']['name']}"
version = "#{node.default['extension']['version']}"
os = "#{node.default['extension']['os']}"
tmp_dir = "#{node.default['activegate']['tmp_dir']}"
extension_dir = "#{node.default['activegate']['extension_dir']}"

log 'install_log' do
    message "Install - Local Variable - #{name}, #{version}, #{os}"
    level :info
end  

#Download ZIP file
remote_file "#{node.default['extension']['name']}.zip" do
    source "#{node['download_repo']}/custom.remote.python.#{name}/custom.remote.python.#{name}-#{version}#{os}.zip"
    path "#{tmp_dir}/custom.remote.python.#{name}.zip"
    owner 'dtuserag'
    group 'dtuserag'
    mode '0755'
end

# Remove existing version (if exists)
directory 'remove_extension_dir' do
    path "#{extension_dir}/custom.remote.python.#{name}"
    recursive true
    action :delete
    only_if { File.exist? "#{extension_dir}/custom.remote.python.#{name}"}
end

# Install 'unzip' if not present
package 'unzip' do
    action :install
end

# Extract new ZIP file to location
execute 'extract_extension_zip' do
    user "dtuserag"
    command "unzip #{tmp_dir}/custom.remote.python.#{name}.zip -d #{extension_dir}/"
end

# Restart remoteplugin module
service 'remotepluginmodule' do
    action :restart
end


# Make API call to update plugin in Web UI