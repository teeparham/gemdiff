module Gemdiff
  class OutdatedGem
    attr_accessor :name, :old_version, :new_version

    def initialize(name, old_version=nil, new_version=nil)
      @name = name
      @old_version = old_version
      @new_version = new_version
    end

    # options :old, :new
    def set_versions(options)
      @old_version = options[:old]
      @new_version = options[:new]
    end

    def missing_versions?
      old_version.nil? || new_version.nil?
    end

    def load_bundle_versions
      gem = BundleInspector.new.get(gem_name)
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

    def compare_message
      "#{name}: #{new_version} > #{old_version}"
    end

    def compare_url
      "#{repo}/compare/v#{old_version}...v#{new_version}"
    end

    def open
      `open #{compare_url}` if repo?
    end
  end
end
