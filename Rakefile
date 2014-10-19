begin
  require 'fileutils'
rescue LoadError => e
  puts "Could not load required library - #{e}"
end  

begin
  puppet_lib_dir = ENV["PUPPET_LIB"] || $:.first
rescue => e 
  puts e
  exit 1
end

namespace :bootstrap do
  desc "Copies the appropriate files to Puppet's default plugindest, or a directory of your choosing via PUPPET_LIB"
  task :copy_files do
    begin
      FileUtils.mkdir_p File.join(puppet_lib_dir, 'hiera/backend')
      FileUtils.cp_r 'lib/hiera/backend/fancyass_backend.rb', File.join(puppet_lib_dir, 'hiera/backend')
      FileUtils.cp_r 'fancyass_wardrobe', File.join(puppet_lib_dir, 'hiera/backend')
      FileUtils.chmod_R 0755, File.join(puppet_lib_dir, 'hiera/backend')
      puts "Successfully deployed fancyass to #{File.join(puppet_lib_dir, 'hiera/backend')}"
    rescue => e
      puts "There was an error deploying fancyass - #{e.message}\nBacktrace:\n#{e.backtrace}"
      exit 1
    end
  end
end

task :default => 'bootstrap:copy_files'
