# frozen_string_literal: true

require "thor"

module Gemdiff
  class CLI < Thor
    include Thor::Actions
    include Colorize

    default_task :list

    CHECKING_FOR_OUTDATED = "Checking for outdated gems in your bundle..."
    NOTHING_TO_UPDATE = "Nothing to update."
    WORKING_DIRECTORY_IS_NOT_CLEAN = "Your working directory is not clean. Please commit or stash before updating."
    RESPONSES_ALL = %w[s A].freeze
    RESPONSES_COMPARE = %w[y A].freeze

    desc "find <gem>", "Find the github repository URL for a gem"
    def find(gem_name)
      outdated_gem = OutdatedGem.new(gem_name)
      if outdated_gem.repo?
        puts outdated_gem.repo
      else
        puts "Could not find github repository for #{gem_name}."
      end
      outdated_gem
    end

    desc "open <gem>", "Open the github repository for a gem"
    def open(gem_name)
      find(gem_name).open
    end

    desc "releases <gem>", "Open the github releases page for a gem"
    def releases(gem_name)
      find(gem_name).releases
    end

    desc "main <gem>", "Open the github main branch commits page for a gem"
    def main(gem_name)
      find(gem_name).main
    end

    desc "compare <gem> [<old> <new>]", <<~DESC
      Compare gem versions. Opens the compare view between the specified new and old versions.
      If versions are not specified, your bundle is inspected and the latest version of the
      gem is compared with the current version in your bundle.
    DESC
    def compare(gem_name, old_version = nil, new_version = nil)
      outdated_gem = find(gem_name)
      return unless outdated_gem.repo?
      outdated_gem.set_versions old_version, new_version
      if outdated_gem.missing_versions?
        puts CHECKING_FOR_OUTDATED
        unless outdated_gem.load_bundle_versions
          puts "#{gem_name} is not outdated in your bundle. Specify versions."
          return
        end
      end
      puts outdated_gem.compare_message
      outdated_gem.compare
    end

    desc "each", "Compare each outdated gem in the bundle. You will be prompted to open each compare view."
    def each
      puts CHECKING_FOR_OUTDATED
      inspector = BundleInspector.new
      puts inspector.outdated
      all_action = false
      inspector.list.each do |outdated_gem|
        puts outdated_gem.compare_message
        response = all_action || ask("Open? (y to open, x to exit, A to open all, s to show all to stdout, else skip)")
        all_action = response if RESPONSES_ALL.include?(response)
        outdated_gem.compare if RESPONSES_COMPARE.include?(response)
        puts outdated_gem.compare_url if response == "s"
        break if response == "x"
      end
    end
    map outdated: :each

    desc "list", "List compare URLs for all outdated gems in the bundle."
    def list
      puts CHECKING_FOR_OUTDATED
      inspector = BundleInspector.new
      puts inspector.outdated
      puts "\n"
      inspector.list.each do |outdated_gem|
        puts outdated_gem.compare_message
        puts outdated_gem.compare_url
        puts "\n"
      end
    end

    desc "update <gem>", "Update a gem, show a git diff of the update, and commit or reset"
    def update(name)
      gem_updater = GemUpdater.new(name)
      puts WORKING_DIRECTORY_IS_NOT_CLEAN unless gem_updater.clean?
      puts "Updating #{name}..."
      gem_updater.update
      diff_output = colorize_git_output(gem_updater.diff)
      puts diff_output
      if diff_output.empty?
        puts NOTHING_TO_UPDATE
        return
      end
      response = ask("\nCommit? (c to commit, r to reset, else do nothing)")
      case response
      when "c"
        gem_updater.commit
        puts "\n#{colorize_git_output(gem_updater.show)}"
      when "r"
        puts gem_updater.reset
      end
    end
  end
end
