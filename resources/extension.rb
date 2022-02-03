# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
resource_name :extension

# unified_mode true

property :name, String, name_property: true
property :version, String
property :os, String
property :extension_repo, String
property :extension_dir, String
property :tmp_dir, String
property :tenancy_url, String
property :api_token, String


action :install do
    extension_repo =  new_resource.extension_repo
    name =  new_resource.name
    version =  new_resource.version
    os = new_resource.os
    tmp_dir =  new_resource.tmp_dir
    extension_dir = new_resource.extension_dir

    extend ActivegateExtensions::Exists
    if install_ext?("#{extension_dir}/custom.remote.python.#{name}/plugin.json", "#{version}")
        #Download ZIP file
        remote_file "download_zip" do
            source "#{extension_repo}/custom.remote.python.#{name}/custom.remote.python.#{name}-#{version}#{os}.zip"
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
            only_if { ::Dir.exist?("#{extension_dir}/custom.remote.python.#{name}") }           
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
    end
end

action :upload do
    name =  new_resource.name
    version =  new_resource.version   
    tmp_dir =  new_resource.tmp_dir    
    tenancy_url = new_resource.tenancy_url
    api_token = new_resource.api_token

    require 'uri'
    require 'net/http'
    require 'json'

    # GET Plugin Status    
    url = URI("#{tenancy_url}/api/config/v1/plugins/custom.remote.python.#{name}")    
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Get.new(url)
    request["Authorization"] = "Api-Token #{api_token}"
    get_response = https.request(request)

    # POST Plugin Status
    url = URI("#{tenancy_url}/api/config/v1/plugins/")
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "Api-Token #{api_token}"
    form_data = [['file', ::File.open("#{tmp_dir}/custom.remote.python.#{name}.zip")]]
    request.set_form form_data, 'multipart/form-data'
    
    # Check extension version in tenancy and upload
    if get_response.kind_of?(Net::HTTPOK)
        # Check version 
        response_json = JSON.parse(get_response.read_body)
        ext_version = response_json['version']
        puts "Tenancy #{name} version is #{ext_version}"

        if ext_version != version
            # Upload new version
            post_response = https.request(request)
            puts post_response
            puts "Extension #{name} updated"
        else
            puts "Extension #{name} already on the required version"
        end
    else
        # Upload extension
        post_response = https.request(request)
        puts post_response
        puts "Extension #{name} uploaded to tenancy"
    end   
end