# frozen_string_literal: true

require "octokit"
require "yaml"

module Gemdiff
  module RepoFinder
    GITHUB_REPO_REGEX = %r{(https?)://(www.)?github\.com/([\w.%-]*)/([\w.%-]*)}.freeze

    # rails builds several gems that are not individual projects
    # some repos move and the old repo page still exists
    # some repos are not mostly ruby so the github search doesn't find them
    REPO_EXCEPTIONS =
      {
        actioncable:              "rails/rails",
        actionmailer:             "rails/rails",
        actionpack:               "rails/rails",
        actionview:               "rails/rails",
        activejob:                "rails/rails",
        activemodel:              "rails/rails",
        activerecord:             "rails/rails",
        activesupport:            "rails/rails",
        "aws-sdk-rails":          "aws/aws-sdk-rails",
        bluepill:                 "bluepill-rb/bluepill",
        chunky_png:               "wvanbergen/chunky_png",
        "color-schemer":          "at-import/color-schemer",
        delayed_job:              "collectiveidea/delayed_job",
        execjs:                   "rails/execjs",
        factory_girl:             "thoughtbot/factory_bot",
        factory_girl_rails:       "thoughtbot/factory_bot_rails",
        faraday_middleware:       "lostisland/faraday_middleware",
        flamegraph:               "SamSaffron/flamegraph",
        ffi:                      "ffi/ffi",
        "foundation-rails":       "zurb/foundation-rails",
        googleauth:               "google/google-auth-library-ruby",
        gosu:                     "jlnr/gosu",
        grpc:                     "google/grpc",
        "guard-livereload":       "guard/guard-livereload",
        "jquery-ujs":             "rails/jquery-ujs",
        json:                     "flori/json",
        kaminari:                 "kaminari/kaminari",
        "kaminari-actionview":    "kaminari/kaminari",
        "kaminari-activerecord":  "kaminari/kaminari",
        "kaminari-core":          "kaminari/kaminari",
        "libxml-ruby":            "xml4r/libxml-ruby",
        "minitest-reporters":     "kern/minitest-reporters",
        "modular-scale":          "modularscale/modularscale-sass",
        msgpack:                  "msgpack/msgpack-ruby",
        "net-ssh-gateway":        "net-ssh/net-ssh-gateway",
        newrelic_rpm:             "newrelic/rpm",
        nokogiri:                 "sparklemotion/nokogiri",
        nokogumbo:                "rubys/nokogumbo",
        nsa:                      "localshred/nsa",
        oauth:                    "oauth-xx/oauth-ruby",
        oj:                       "ohler55/oj",
        passenger:                "phusion/passenger",
        pg:                       "ged/ruby-pg",
        "pkg-config":             "ruby-gnome2/pkg-config",
        "pry-doc":                "pry/pry-doc",
        public_suffix:            "weppos/publicsuffix-ruby",
        pundit:                   "varvet/pundit",
        "rack-protection":        "sinatra/sinatra",
        rails_multisite:          "discourse/rails_multisite",
        railties:                 "rails/rails",
        rake:                     "ruby/rake",
        resque:                   "resque/resque",
        "rb-fsevent":             "thibaudgg/rb-fsevent",
        "resque-multi-job-forks": "stulentsev/resque-multi-job-forks",
        representable:            "trailblazer/representable",
        rr:                       "rr/rr",
        sass:                     "sass/ruby-sass",
        SassyLists:               "at-import/SassyLists",
        "Sassy-Maps":             "at-import/Sassy-Maps",
        "sassy-math":             "at-import/Sassy-math",
        settingslogic:            "settingslogic/settingslogic",
        sinatra:                  "sinatra/sinatra",
        "sinatra-contrib":        "sinatra/sinatra",
        stripe:                   "stripe/stripe-ruby",
        thread_safe:              "ruby-concurrency/thread_safe",
        tolk:                     "tolk/tolk",
        toolkit:                  "at-import/tookit",
        "trailblazer-cells":      "trailblazer/trailblazer-cells",
        turbolinks:               "turbolinks/turbolinks",
        "twitter-text":           "twitter/twitter-text",
        ox:                       "ohler55/ox",
        zeus:                     "burke/zeus",
      }.freeze

    class << self
      # Try to get the homepage from the gemspec
      # If not found, search github
      def github_url(gem_name)
        gemspec_homepage(gem_name) || search(gem_name)
      end

      private

      def gemspec_homepage(gem_name)
        if (full_name = REPO_EXCEPTIONS[gem_name.to_sym])
          return github_repo(full_name)
        end
        return nil unless (yaml = gemspec(gem_name))
        spec = YAML.load(yaml)
        return secure_url(spec.homepage) if spec.homepage =~ GITHUB_REPO_REGEX
        match = spec.description.match(GITHUB_REPO_REGEX) if spec.description
        match && secure_url(match[0])
      end

      def secure_url(url)
        url.gsub(/\Ahttp:/, "https:")
      end

      def search(gem_name)
        query = "#{gem_name} language:ruby in:name"
        result = octokit_client.search_repositories(query)
        return nil if result.items.empty?
        github_repo result.items.first.full_name
      end

      def github_repo(full_name)
        "https://github.com/#{full_name}"
      end

      def access_token
        ENV["GEMDIFF_GITHUB_TOKEN"] || ENV["GITHUB_TOKEN"]
      end

      def octokit_client
        Octokit::Client.new(access_token: access_token)
      end

      def gemspec(name)
        local = find_local_gemspec(name)
        return find_remote_gemspec(name) unless last_shell_command_success?
        local.partition("#").first if local =~ GITHUB_REPO_REGEX
      end

      def last_shell_command_success?
        $CHILD_STATUS.success?
      end

      def find_local_gemspec(name)
        `gem spec #{name}`
      end

      def find_remote_gemspec(name)
        `gem spec -r #{name}` if last_shell_command_success?
      end
    end
  end
end
