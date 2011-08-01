#!/usr/bin/env ruby

require 'yaml'
require 'pathname'
require 'find'
require 'fileutils'

class Gsubfile
  attr_accessor :path
  attr_accessor :config
  
  def initialize(argv = [])
    if argv.count < 2
      usage
    else
      load_config(ARGV[0])
      self.path = ARGV[1]
    end
  end
  
  def load_config(config_file)
    self.config = YAML.load_file(config_file)
    self.config[:git_command] ||= false
  end
  
  def execute!
    replace(self.path)
    puts "Replace successful."
  end
  
  def self.usage
    puts "Usage: gsubfile config_file folder"
  end
  
  private
  
  def replace(root_path)
    search_path = (Pathname.new(root_path) + "*").to_s
    Dir.glob(search_path).each do |p|
      puts "Processing #{p} ..."
      pathname = replace_name(p)
      if FileTest.directory?(pathname)
        replace(pathname)
      elsif FileTest.file?(pathname)
        replace_content(pathname)
      end
    end
  end
  
  def replace_name(path)
    p = Pathname.new(path)
    new_basename = p.basename.to_s
    self.config['pattern'].sort.map { |g| g[1] }.each do |h|
      h.each { |s, r| new_basename.gsub!(/#{s}/, r) }
    end
    new_pathname = (p.dirname + new_basename).to_s
    git_mv(p.to_s, new_pathname) unless new_basename == p.basename.to_s
    new_pathname
  end
  
  def replace_content(file)
    buffer = File.new(file, 'r').read
    self.config['pattern'].sort.map { |g| g[1] }.each do |h|
      h.each { |s, r| buffer.gsub!(/#{s}/, r) }
    end
    File.open(file, 'w') { |f| f.write(buffer) }
    git_add(file)
  end
  
  def git_mv(source, dest)
    if self.config['git_command']
      system("cd #{self.path} && git mv '#{source}' '#{dest}'")
    else
      FileUtils.mv(source, dest)
    end
  end
  
  def git_add(file)
    if self.config['git_command']
      system("cd #{self.path} && git add '#{file}'")
    end
  end
end

Gsubfile.new(ARGV).execute!
