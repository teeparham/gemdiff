require 'thor'

module Gemdiff
  class CLI < Thor
    include Thor::Actions
    include Colorize

    default_task :outdated

    CHECKING_FOR_OUTDATED = "Checking for outdated gems in your bundle..."
    NOTHING_TO_UPDATE = "Nothing to update."
    WORKING_DIRECTORY_IS_NOT_CLEAN = "Your working directory is not clean. Please commit or stash before updating."

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

    desc 'master <gem>', 'Open the github master branch commits page for a gem'
    def master(gem_name)
      gem = find(gem_name)
      gem.master
    end

    desc 'compare <gem> [<old> <new>]', <<DESC
Compare gem versions. Opens the compare view between the specified new and old versions.
If versions are not specified, your bundle is inspected and the latest version of the
gem is compared with the current version in your bundle.
DESC
    def compare(gem_name, old_version = nil, new_version = nil)
      gem = find(gem_name)
      return unless gem.repo?
      gem.set_versions old_version, new_version
      if gem.missing_versions?
        puts CHECKING_FOR_OUTDATED
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
      puts CHECKING_FOR_OUTDATED
      inspector = BundleInspector.new
      puts inspector.outdated
      inspector.list.each do |gem|
        puts gem.compare_message
        response = ask("Open? (y to open, x to exit, else skip)")
        gem.compare if response == 'y'
        return if response == 'x'
      end
    end

    desc 'update <gem>', 'Update a gem, show a git diff of the update, and commit or reset'
    def update(name)
      gem = GemUpdater.new(name)
      unless gem.clean?
        puts WORKING_DIRECTORY_IS_NOT_CLEAN
      end
      puts "Updating #{name}..."
      gem.update
      diff_output = colorize_git_output(gem.diff)
      puts diff_output
      if diff_output.empty?
        puts NOTHING_TO_UPDATE
        return
      end
      response = ask("\nCommit? (c to commit, r to reset, else do nothing)")
      if response == 'c'
        gem.commit
        puts "\n" + colorize_git_output(gem.show)
      elsif response == 'r'
        puts gem.reset
      end
    end
  end
end
