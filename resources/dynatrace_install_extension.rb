# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
resource_name :dynatrace_install_extension

property :name, String, name_property: true
property :version, String
property :os, String
property :download_repo, String
property :extension_dir, String
property :tmp_dir, String

# version = "#{node.default['extension']['version']}"
# os = "#{node.default['extension']['os']}"
# tmp_dir = "#{node.default['activegate']['tmp_dir']}"
# extension_dir = "#{node.default['activegate']['extension_dir']}"

action :install do
    download_repo =  new_resource.download_repo,
    name =  new_resource.name,
    version =  new_resource.version,
    os = new_resource.os,
    tmp_dir =  new_resource.tmp_dir
    extension_dir = new_resource.extension_dir
    #Download ZIP file
    remote_file "download_zip" do
        source "https://dt-cdn.net/hub/extensions/custom.remote.python.#{name}/custom.remote.python.#{name}-#{version}#{os}.zip"
        path "#{tmp_dir}/custom.remote.python.#{name}.zip"
        owner 'dtuserag'
        group 'dtuserag'
        mode '0755'
        # variables(
        #     download_repo: new_resource.download_repo,
        #     name: new_resource.name,
        #     version: new_resource.version,
        #     os: new_resource.os,
        #     tmp_dir: new_resource.tmp_dir
        # )    
    end

    # Remove existing version (if exists)
    directory 'remove_extension_dir' do
        path "#{extension_dir}/custom.remote.python.#{name}"
        recursive true
        action :delete
        # only_if { File.exist? "#{extension_dir}/custom.remote.python.#{name}"}
        # variables(        
        #     name: new_resource.name,      
        #     tmp_dir: new_resource.tmp_dir,
        #     extension_dir: new_resource.extension_dir
        # )
    end

    # Install 'unzip' if not present
    package 'unzip' do
        action :install
    end

    # Extract new ZIP file to location
    execute 'extract_extension_zip' do
        user "dtuserag"
        command "unzip #{tmp_dir}/custom.remote.python.#{name}.zip -d #{extension_dir}/"
        # variables(        
        #     name: new_resource.name,        
        #     tmp_dir: new_resource.tmp_dir,
        #     extension_dir: new_resource.extension_dir
        # )
    end

    # Restart remoteplugin module
    service 'remotepluginmodule' do
        action :restart
    end
end