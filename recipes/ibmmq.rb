#
# Cookbook:: plugin_update
# Recipe:: update
#
# Copyright:: 2022, The Authors, All Rights Reserved.

# Download ZIP file
remote_file 'custom.remote.python.ibmmq_java.zip' do
    source 'https://dt-cdn.net/hub/extensions/custom.remote.python.ibmmq_java/custom.remote.python.ibmmq_java-2.021.0.zip'
    path '/var/tmp/custom.remote.python.ibmmq_java.zip'
    owner 'dtuserag'
    group 'dtuserag'
    mode '0755'
end

# Remove existing version (if exists)

file '/opt/dynatrace/remotepluginmodule/plugin_deployment/custom.remote.python.ibmmq_java.zip' do
    path '/opt/dynatrace/remotepluginmodule/plugin_deployment/custom.remote.python.ibmmq_java'
    action :delete
    only_if { File.exist? '/opt/dynatrace/remotepluginmodule/plugin_deployment/custom.remote.python.ibmmq_java'}
end

package 'unzip' do
    action :install
end


# Extract new ZIP file to location
execute 'extract_extension_zip' do
    user "dtuserag"
    command "unzip /var/tmp/custom.remote.python.ibmmq_java.zip -d /opt/dynatrace/remotepluginmodule/plugin_deployment/"
end

# Restart remoteplugin module
service 'remotepluginmodule' do
    action :restart
end


# Make API call to update plugin in Web UI