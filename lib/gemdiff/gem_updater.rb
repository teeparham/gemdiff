# frozen_string_literal: true

module Gemdiff
  class GemUpdater
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def update
      bundle_update
    end

    def diff
      git_diff
    end

    def show
      git_show
    end

    def commit
      git_commit
    end

    def reset
      git_reset
    end

    def clean?
      git_diff.empty?
    end

    private

    def git_show
      `git show`
    end

    def git_diff
      `git diff`
    end

    def git_commit
      return false if git_added_line.empty?
      git_add_and_commit_lockfile
      true
    end

    def version(changed_line)
      changed_line.split("\n").first.split(" ").last.gsub(/[()]/, "")
    end

    # example returns:
    # +    rails (4.2.3)
    # or
    # +    sass-rails (4.0.3)
    # +  sass-rails
    # or
    # +      activejob (= 4.2.3)
    # +    activejob (4.2.3)
    # +      activejob (= 4.2.3)
    def git_added_line
      @git_added_line ||= `git diff | grep ' #{name} (' | grep '+  '`
    end

    # example returns:
    # -    json (1.8.1)
    def git_removed_line
      `git diff | grep ' #{name} (' | grep '\\-  '`
    end

    def commit_message
      new_version = version(git_added_line)
      outdated = OutdatedGem.new(name, new_version, version(git_removed_line))
      "Update #{name} to #{new_version}\n\n#{outdated.compare_url}"
    end

    def git_add_and_commit_lockfile
      `git add Gemfile.lock && git commit -m '#{commit_message}'`
    end

    def git_reset
      `git checkout Gemfile.lock`
    end

    def bundle_update
      `bundle update #{name}`
    end
  end
end
