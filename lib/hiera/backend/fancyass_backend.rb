#!/usr/bin/env ruby

class Hiera
module Backend
  class Fancyass_backend
    
    attr_reader :debug
    
    def initialize
      begin
        Dir.glob("#{File.dirname(__FILE__)}/fancyass_wardrobe/*/*.rb").each { |file| require file }
        require 'json'
        require 'yaml'
      rescue => e
        raise "Fancyass: Could not load required library - #{e}"
      end
      
      # Dynamically get a list of available trousers, which should be located in the fancyass_wardrove/trousers directory
      available_trousers = Dir.glob("#{File.dirname(__FILE__)}/fancyass_wardrobe/trousers/*.rb").each.inject([]) do |selection, file|
        selection << file.split('/').last.chomp('.rb')
      end
      unless available_trousers.include?(Config[:fancyass][:trouser])
        raise "Fancyass: Invalid choice of trousers - #{Config[:fancyass][:trouser]} - Acceptable values: #{available_trousers}"
      end
      
      @trouser = Object.const_get("Hiera::Backend::Fancyass::" + Config[:fancyass][:trouser].capitalize).new
      Config[:fancyass][:debug] == true ? @debug = true : @debug = false
     
      Hiera.debug("Hiera Fancyass backend starting")
    end

    def lookup(key, scope, order_override, resolution_type)
      Hiera.debug("Looking up #{key} in Fancyass backend") if @debug
      Hiera.debug("Fancyass: using order_override: #{order_override}") if @debug
      Hiera.debug("Fancyass: using resolution_type: #{resolution_type}") if @debug
      
      @trouser.lookup key, scope, order_override, resolution_type
    end
  end # End Fancyass_backend
end # End Backend module
end # End Hiera class
