require 'thor'

module Gemdiff
  class CLI < Thor
    default_task :outdated

    desc 'find', 'find github repository URL for a gem'
    def find(gem_name)
      repo = RepoFinder.github_url(gem_name)
      puts "Could not find github repository for #{gem_name}." unless repo
      puts repo
      repo
    end

    desc 'open', 'open github repository for a gem'
    def open(gem_name)
      repo = find(gem_name)
      `open #{repo}` if repo
    end

    desc 'compare', 'compare gem versions'
    method_option :new, aliases: '-n', desc: 'new gem version'
    method_option :old, aliases: '-o', desc: 'old gem version'
    #method_option :prompt, aliases: '-p', desc: 'prompt before opening the compare view'
    options old: :string, new: :string
    def compare(gem_name)
      repo = find(gem_name)
      old_version = options[:old]
      new_version = options[:new]
      if old_version.nil? || new_version.nil?
        puts "Checking for outdated gems in your bundle..."
        unless (gem = BundleInspector.new.get(gem_name))
          puts "#{gem_name} is not oudated in your bundle. Specify versions."
          return
        end
        old_version ||= gem.old_version
        new_version ||= gem.new_version
      end
      puts "Comparing #{old_version} to #{new_version}"
      `open #{repo}/compare/v#{old_version}...v#{new_version}`
    end

    desc 'outdated', 'compare each outdated gem in the bundle'
    def outdated
      puts "Checking for outdated gems in your bundle..."
      inspector = BundleInspector.new
      inspector.list.each do |gem|
        # todo
        puts gem.name
      end
    end
  end
end
