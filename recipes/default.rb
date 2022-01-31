#
# Cookbook:: activegate_extensions
# Recipe:: default
#
# Copyright:: 2022, The Authors, All Rights Reserved.

# Check Version if file on host
node['extensions'].each do |name, properties|    
    
    log 'version' do
        message "#{name} extension version is #{properties['version']}"
        level :info
    end
    
    ruby_block "extension version" do
        block do
            require 'json'
            
            # change default values
            node.default['extension']['name'] = "#{name}"
            node.default['extension']['version'] = "#{properties['version']}"
            node.default['extension']['os'] = "#{properties['os']}"
            
            # Open file (if exists) and check version
            if File.exist?("#{node['activegate']['extension_dir']}/custom.remote.python.#{name}/plugin.json")
                File.open("#{node['activegate']['extension_dir']}/custom.remote.python.#{name}/plugin.json") do |f|                    
                    data_hash = JSON.parse(f.read)                    
                    # Update extension - if not required version
                    if data_hash['version'] != "#{properties['version']}"
                        run_context.include_recipe "activegate_extensions::install"
                    else
                        p "Extension #{name} is on the latest version"
                    end
                    f.close
                end
            else
                # Install extension if does not exist
                run_context.include_recipe "activegate_extensions::install"
            end            
        end
        action :run        
    end      
end
