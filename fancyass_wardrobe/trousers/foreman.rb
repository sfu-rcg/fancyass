#!/usr/bin/env ruby

class Hiera
module Backend
module Fancyass
  class Foreman
    def initialize(debug=false)
      begin
        require 'yaml'
      rescue => e
        raise "Fancyass: Could not load required library - #{e}"
      end
      
      @url  = Config[:fancyass][:foreman][:url]
      @user = Config[:fancyass][:foreman][:user]
      @password = Config[:fancyass][:foreman][:password]
      # This will be used as the key for the scope hash, which is HUGE. Common examples: fqdn, clientcert, macaddress
      @search_key = Config[:fancyass][:foreman][:search_key]
      Config[:fancyass][:foreman][:output][:disk] == true ? @output_to_disk = true : @output_to_disk = false
      @debug = debug
      
      if @output_to_disk
        @output_format = Config[:fancyass][:foreman][:output][:format]
        raise "Fancyass: Invalid output format - #{@output_format} - Acceptable values: yaml, json" unless ['yaml', 'json'].include? @output_format
      end
      
      @connection = Hiera::Backend::Fancyass.http_connect @url, @debug, @user, @password
      
      # Used for the lookup method
      @timestamp = nil
      @values = {}
    end

    def lookup(key, scope, order_override, resolution_type)
      unless @timestamp == scope['_timestamp']
        # Since The Foreman will return all its values at once, we only
        # need to contact it once during a node's run. This is done using timestamps
        @values = YAML::load Fancyass.get_request(@connection, "/param_lookup?#{@search_key}=#{scope[@search_key]}", 'The Foreman')
        @timestamp = scope['_timestamp']
        # Allows you to merge values with other Hiera datasources
        if @output_to_disk
          hiera_data_dir = Fancyass.determine_data_dir
          hiera_data_dir = Fancyass.interpolate_string hiera_data_dir, scope
          write_to_disk hiera_data_dir, scope[@search_key], @values
          return nil
        end
      end
      
      if @output_to_disk == false
        # If we're not writing the results to disk, just return the value for the requested key
        # Keys that don't exist return nil
        return @values[key]
      end
      
      return nil
    end #End lookup method

    private
      def write_to_disk(dir, identifier, content)
        begin
          content = nil if content.empty?
          path = File.join(dir, "#{identifier}.#{@output_format}")
          File.open(path, 'w') do |f| 
              f.write content.send "to_#{@output_format}" 
          end
        rescue => e
          raise "Fancyass: There was an error writing the output to a file - #{e.message}"
        end
      end
  end # End Foreman class
end # End Fancyass module
end # End Backend module
end # End Hiera class
