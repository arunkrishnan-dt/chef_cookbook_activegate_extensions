#
# Chef Infra Documentation
# https://docs.chef.io/libraries/
#

# This module checks if an extension needs installed/updated
module ActivegateExtensions
  module Exists   
    def install_ext?(path, version)
      if File.exist?(path)
        File.open("#{path}") do |f|                    
          data_hash = JSON.parse(f.read)
          if data_hash['version'] != version
            return true
          end
        end
      else
        return true
      end
    end     
  end
end
