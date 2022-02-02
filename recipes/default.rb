#
# Cookbook:: activegate_extensions
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.

# Check Version if file on host
node['extensions'].each do |name, properties|    
    
    log 'attribute_file_version' do
        message "Attribute file version: #{name} - #{properties['version']}"
        level :info
    end    

    if File.exist?("#{node['activegate']['extension_dir']}/custom.remote.python.#{name}/plugin.json")
        File.open("#{node['activegate']['extension_dir']}/custom.remote.python.#{name}/plugin.json") do |f|                    
            data_hash = JSON.parse(f.read)                    

            log 'server_version' do
                message "Existing server version: #{name} - #{data_hash['version']}"
                level :info
            end 

            # Update extension - if exists & not on required version
            if data_hash['version'] != "#{properties['version']}"
                activegate_extensions_install_extension "#{name}" do
                    version "#{properties['version']}"                       
                    os "#{properties['os']}"
                    download_repo "#{node.default['download_repo']}"
                    extension_dir "#{node.default['activegate']['extension_dir']}"
                    tmp_dir "#{node.default['activegate']['tmp_dir']}"        
                    action :install
                end    

                activegate_extensions_upload_extension "#{name}" do
                    version "#{properties['version']}"                
                    tmp_dir "#{node.default['activegate']['tmp_dir']}"        
                    tenancy_url "#{node.default['dynatrace']['tenancy_url']}"
                    api_token "#{node.default['dynatrace']['api_token']}" # Token attribute file is local and not in repository
                    action :upload
                end

                log 'updated_version' do
                    message "Extension updated to  #{name} - #{properties['version']}"
                    level :info
                end 
            end
        end
    else
        # Add new extension
        activegate_extensions_install_extension "#{name}" do
            version "#{properties['version']}"                       
            os "#{properties['os']}"
            download_repo "#{node.default['download_repo']}"
            extension_dir "#{node.default['activegate']['extension_dir']}"
            tmp_dir "#{node.default['activegate']['tmp_dir']}"        
            action :install
        end    

        activegate_extensions_upload_extension "#{name}" do
            version "#{properties['version']}"                
            tmp_dir "#{node.default['activegate']['tmp_dir']}"        
            tenancy_url "#{node.default['dynatrace']['tenancy_url']}"
            api_token "#{node.default['dynatrace']['api_token']}" # Token attribute file is local and not in repository
            action :upload
        end

        log 'installed_version' do
            message "Installed extension #{name} - #{properties['version']}"
            level :info
        end
    end      
end
