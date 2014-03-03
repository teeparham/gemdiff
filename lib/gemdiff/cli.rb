require 'thor'

module Gemdiff
  class CLI < Thor
    include Colorize

    default_task :outdated

    desc 'find <gem>', 'Find the github repository URL for a gem'
    def find(gem_name)
      gem = OutdatedGem.new(gem_name)
      if gem.repo?
        puts gem.repo
      else
        puts "Could not find github repository for #{gem_name}."
      end
      gem
    end

    desc 'open <gem>', 'Open the github repository for a gem'
    def open(gem_name)
      gem = find(gem_name)
      gem.open
    end

    desc 'releases <gem>', 'Open the github releases page for a gem'
    def releases(gem_name)
      gem = find(gem_name)
      gem.releases
    end

    desc 'commits <gem>', 'Open the github master branch commits page for a gem'
    def commits(gem_name)
      gem = find(gem_name)
      gem.commits
    end

    desc 'compare <gem> [<versions>...]', <<DESC
Compare gem versions. Opens the compare view between the specified new and old versions.
If versions are not specified, your bundle is inspected and the latest version of the
gem is compared with the current version in your bundle.
DESC
    method_option :new, aliases: '-n', desc: 'new gem version'
    method_option :old, aliases: '-o', desc: 'old gem version'
    def compare(gem_name)
      gem = find(gem_name)
      return unless gem.repo?
      gem.set_versions options
      if gem.missing_versions?
        puts "Checking for outdated gems in your bundle..."
        unless gem.load_bundle_versions
          puts "#{gem_name} is not outdated in your bundle. Specify versions."
          return
        end
      end
      puts gem.compare_message
      gem.compare
    end

    desc 'outdated', 'Compare each outdated gem in the bundle. You will be prompted to open each compare view.'
    def outdated
      puts "Checking for outdated gems in your bundle..."
      inspector = BundleInspector.new
      inspector.list.each do |gem|
        puts gem.compare_message
        response = ask("Open? (y to open, else skip)")
        gem.compare if response == 'y'
      end
    end

    desc 'update <gem>', 'Update a gem, show a git diff of the update, and commit or reset'
    def update(name)
      puts "Updating #{name}..."
      gem = GemUpdater.new(name)
      gem.update
      puts colorize_diff(gem.diff)
      response = ask("Commit? (c to commit, r to reset, else do nothing")
      puts gem.commit if response == 'c'
      puts gem.reset if response == 'r'
    end
  end
end
