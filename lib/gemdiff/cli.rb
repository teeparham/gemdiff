require 'thor'

module Gemdiff
  class CLI < Thor
    default_task :outdated

    desc 'find', 'Find the github repository URL for a gem'
    def find(gem_name)
      repo = RepoFinder.github_url(gem_name)
      puts "Could not find github repository for #{gem_name}." unless repo
      puts repo
      repo
    end

    desc 'open', 'Open the github repository for a gem'
    def open(gem_name)
      repo = find(gem_name)
      `open #{repo}` if repo
    end

    desc 'compare', 'Compare gem versions. Opens the compare view between the specified new and old versions. If versions are not specified, your bundle is inspected and the latest version of the gem is compared with the current version in your bundle.'
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

    desc 'outdated', 'Compare each outdated gem in the bundle. You will be prompted to open each compare view.'
    method_option :no_skip, aliases: '-s', desc: 'skip warning about tag format'
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
