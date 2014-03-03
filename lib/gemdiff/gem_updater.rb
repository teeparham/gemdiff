module Gemdiff
  class GemUpdater
    attr_accessor :name

    def initialize(name)
      @name = name
    end

    def update
      bundle_update
    end

    def diff
      git_diff
    end

    def commit
      git_commit
    end

    def reset
      git_reset
    end

  private

    def git_diff
      `git diff`
    end

    def git_commit
      added = git_changed_line
      return false if added.empty?
      version = added.split(' ').last.gsub(/[()]/, '')
      git_add_and_commit_lockfile version
      true
    end

    def git_changed_line
      `git diff | grep #{name} | grep '+  '`
    end

    def git_add_and_commit_lockfile(version)
      `git add Gemfile.lock && git commit -m 'Update #{name} to #{version}'`
    end

    def git_reset
      `git checkout Gemfile.lock`
    end

    def bundle_update
      `bundle update #{name}`
    end

  end
end
