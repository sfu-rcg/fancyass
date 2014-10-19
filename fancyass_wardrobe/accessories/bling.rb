#!/usr/bin/env ruby

begin
  require 'faraday'
  require 'net/http'
  require 'net/https'
  require 'uri'
  require 'timeout'
rescue => e
  raise "Fancyass: Could not load required library - #{e}"
end

class Hiera
module Backend
module Fancyass
  class << self
    # Establish a connection to the server
    # - returns a Faraday HTTP client object
    def http_connect(uri, logging, user='', password='')
      uri = URI.parse uri
      conn = Faraday.new(url: uri, ssl: {:verify => false}) do |faraday|
        faraday.request  :url_encoded
        faraday.response :logger if logging
        faraday.adapter  Faraday.default_adapter
      end
      conn.basic_auth user, password unless (user and password).empty?
      conn
    end

    # Ask the server for the specified data
    # - returns the response's body (usually yaml, or json)
    def get_request(connection, url, request_headers = {}, trousers='')
      response = connection.get do |request|
        request_headers.each do |key, value|
          request.headers[key] = value
        end
        request.url url
      end
      unless response.status == 200
        raise "Fancyass: A non-200 response was received from #{trousers} - #{response.status} \nResponse body: - #{response.body}"
      end
      response.body
    end

    def determine_data_dir
      return hiera_data_dir = Config[:yaml][:datadir] unless Config[:yaml][:datadir].nil?
      return hiera_data_dir = '/var/lib/hiera/' if `uname -s`.chomp =~ /Linux|Darwin/
      return hiera_data_dir = "C:/ProgramData/PuppetLabs/hiera/var/" if Facter::Util::Config.is_windows?
      raise "Fancyass: Unknown platform, cannot determine Hiera's data directory"
    end

    def interpolate_string(data, scope, extra_data={})
      Hiera::Backend.parse_string data, scope, extra_data
    end
  end # End class << self
end # End Fancyass module
end # End Backend module
end # End Hiera class
