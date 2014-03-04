module Gemdiff
  class OutdatedGem

    # gems that tag releases with tag names like 1.2.3
    # keep it alphabetical
    LIST_NO_V = %w[atomic babosa cancan compass haml thread_safe]

    attr_accessor :name, :old_version, :new_version

    def initialize(name, old_version = nil, new_version = nil)
      @name = name
      set_versions old_version, new_version
    end

    def set_versions(v_old, v_new)
      v_old, v_new = v_new, v_old if v_old && v_new && v_old > v_new # swap using parallel assignment
      @old_version = v_old
      @new_version = v_new
    end

    def missing_versions?
      @old_version.nil? || @new_version.nil?
    end

    def load_bundle_versions
      gem = BundleInspector.new.get(@name)
      return false if gem.nil?
      @old_version ||= gem.old_version
      @new_version ||= gem.new_version
      true
    end

    def repo
      @repo ||= RepoFinder.github_url(@name)
    end

    def repo?
      !!repo
    end

    def releases_url
      "#{repo}/releases"
    end

    def commits_url
      "#{repo}/commits/master"
    end

    def compare_message
      "#{name}: #{new_version} > #{old_version}"
    end

    def compare_url
      "#{repo}/compare/#{compare_part}"
    end

    def commits
      `open #{commits_url}` if repo?
    end

    def releases
      `open #{releases_url}` if repo?
    end

    def compare
      `open #{compare_url}` if repo?
    end

    def open
      `open #{repo}` if repo?
    end

  private

    def compare_part
      if compare_type == :no_v
        "#{old_version}...#{new_version}"
      else
        "v#{old_version}...v#{new_version}"
      end
    end

    def compare_type
      if LIST_NO_V.include?(@name)
        :no_v
      else
        :default
      end
    end
  end
end
