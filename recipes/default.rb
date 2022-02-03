#
# Cookbook:: activegate_extensions
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.

# Do below for all extensions
node['extensions'].each do |name, properties|    
    
    log 'attribute_file_version' do
        message "Attribute file version: #{name} - #{properties['version']} - #{node.default['extension_repo']} "
        level :info        
    end    

    # Install Extension on ActiveGate
    activegate_extensions_extension "#{name}" do
        extension_repo "#{node.default['extension_repo']}"
        version "#{properties['version']}"                       
        os "#{properties['os']}"        
        extension_dir "#{node.default['activegate']['extension_dir']}"
        tmp_dir "#{node.default['activegate']['tmp_dir']}"
        tenancy_url "#{node.default['dynatrace']['tenancy_url']}"
        api_token "#{node.default['dynatrace']['api_token']}" # Token attribute file is local and not in repository      
        action [:install, :upload]                
    end    

    log 'updated_version' do
        message "Extension version post Chef run -  #{name} - #{properties['version']}"
        level :info
    end
        
end
