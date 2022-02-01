#
# Cookbook:: activegate_extensions
# Recipe:: upload
#
# Copyright:: 2022, The Authors, All Rights Reserved.

name = "#{node.default['extension']['name']}"
version = "#{node.default['extension']['version']}"
os = "#{node.default['extension']['os']}"
tenancy_url = "#{node.default['dynatrace']['tenancy_url']}"
api_token = "#{node.default['dynatrace']['api_token']}" # Token attribute file is local and not in repository
tmp_dir = "#{node.default['activegate']['tmp_dir']}"

ruby_block 'check_version_upload' do
    block do
        require 'uri'
        require 'net/http'
        require 'json'
        
        url = URI("#{tenancy_url}/api/config/v1/plugins/custom.remote.python.#{name}")

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        request = Net::HTTP::Get.new(url)
        request["Authorization"] = "Api-Token #{api_token}"

        # Get Extension Version
        response = https.request(request)
        response_json = JSON.parse(response.read_body)
        ext_version = response_json['version']

        puts "Tenancy #{name} version is #{ext_version}"

        # Check version against variable
        if "#{ext_version}" != "#{version}"
            #rename file
            # File.rename("#{tmp_dir}/custom.remote.python.#{name}-#{version}#{os}.zip", "#{tmp_dir}/custom.remote.python.#{name}.zip")
            #POST the new version
            url = URI("#{tenancy_url}/api/config/v1/plugins/")
            https = Net::HTTP.new(url.host, url.port)
            https.use_ssl = true
            request = Net::HTTP::Post.new(url)
            request["Authorization"] = "Api-Token #{api_token}"
            form_data = [['file', File.open("#{tmp_dir}/custom.remote.python.#{name}.zip")]]
            request.set_form form_data, 'multipart/form-data'
            response = https.request(request)
            puts response.read_body        
        else
            puts "Extension #{name} already on the required version"
        end      
    end
    action :run
end




# Download and rename

# Upload extension