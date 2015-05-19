require 'launchy'

module Gemdiff
  class OutdatedGem

    # gems that tag releases with tag names like 1.2.3
    # keep it alphabetical
    LIST_NO_V = %w[
      atomic
      autoprefixer-rails
      babosa
      cancan
      capybara
      compass
      ffi
      haml
      mail
      rack
      rvm-capistrano
      safe_yaml
      sass
      twilio-ruby
    ]

    attr_accessor :name, :old_version, :new_version

    def initialize(name, old_version = nil, new_version = nil)
      @name = name
      set_versions old_version, new_version
    end

    def set_versions(v_old, v_new)
      @old_version, @new_version = old_new(v_old, v_new)
    end

    def missing_versions?
      @old_version.nil? || @new_version.nil?
    end

    def load_bundle_versions
      outdated_gem = BundleInspector.new.get(@name)
      return false if outdated_gem.nil?
      @old_version ||= outdated_gem.old_version
      @new_version ||= outdated_gem.new_version
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

    def master
      open_url(commits_url) if repo?
    end

    def releases
      open_url(releases_url) if repo?
    end

    def compare
      open_url(compare_url) if repo?
    end

    def open
      open_url(repo) if repo?
    end

  private

    def open_url(url)
      Launchy.open(url) do |exception|
        $stderr.puts "Could not open #{url} because #{exception}"
      end
    end

    def compare_part
      if compare_type == :no_v
        "#{old_version}...#{new_version}"
      else
        # if the new version is not a number, assume it is a branch name
        # and drop the 'v'
        prefix = (new_version[0] =~ /^[0-9]/) == 0 ? 'v' : ''
        "v#{old_version}...#{prefix}#{new_version}"
      end
    end

    def compare_type
      if LIST_NO_V.include?(@name)
        :no_v
      else
        :default
      end
    end

    # swap versions if needed
    def old_new(v_old, v_new)
      return [v_old, v_new] unless v_old && v_new
      if v_old == 'master' || (Gem::Version.new(v_old) > Gem::Version.new(v_new))
        [v_new, v_old]
      else
        [v_old, v_new]
      end
    rescue ArgumentError
      [v_old, v_new]
    end
  end
end
