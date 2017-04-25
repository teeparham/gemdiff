require "octokit"
require "yaml"

module Gemdiff
  module RepoFinder
    GITHUB_REPO_REGEX = /(https?):\/\/(www.)?github\.com\/([\w.%-]*)\/([\w.%-]*)/

    # rails builds several gems that are not individual projects
    # some repos move and the old repo page still exists
    # some repos are not mostly ruby so the github search doesn't find them
    REPO_EXCEPTIONS =
      {
        actionmailer:                "rails/rails",
        actionpack:                  "rails/rails",
        actionview:                  "rails/rails",
        activejob:                   "rails/rails",
        activemodel:                 "rails/rails",
        activerecord:                "rails/rails",
        activesupport:               "rails/rails",
        bluepill:                    "bluepill-rb/bluepill",
        chunky_png:                  "wvanbergen/chunky_png",
        :"color-schemer"          => "at-import/color-schemer",
        delayed_job:                 "collectiveidea/delayed_job",
        execjs:                      "rails/execjs",
        faraday_middleware:          "lostisland/faraday_middleware",
        flamegraph:                  "SamSaffron/flamegraph",
        ffi:                         "ffi/ffi",
        :"foundation-rails"       => "zurb/foundation-rails",
        googleauth:                  "google/google-auth-library-ruby",
        gosu:                        "jlnr/gosu",
        :"guard-livereload"       => "guard/guard-livereload",
        :"jquery-ujs"             => "rails/jquery-ujs",
        json:                        "flori/json",
        kaminari:                    "kaminari/kaminari",
        :"kaminari-actionview"    => "kaminari/kaminari",
        :"kaminari-activerecord"  => "kaminari/kaminari",
        :"kaminari-core"          => "kaminari/kaminari",
        :"modular-scale"          => "modularscale/modularscale-sass",
        :"net-ssh-gateway"        => "net-ssh/net-ssh-gateway",
        newrelic_rpm:                "newrelic/rpm",
        nokogiri:                    "sparklemotion/nokogiri",
        nokogumbo:                   "rubys/nokogumbo",
        oauth:                       "oauth-xx/oauth-ruby",
        oj:                          "ohler55/oj",
        passenger:                   "phusion/passenger",
        pg:                          "ged/ruby-pg",
        :"pry-doc"                => "pry/pry-doc",
        railties:                    "rails/rails",
        rake:                        "ruby/rake",
        resque:                      "resque/resque",
        :"resque-multi-job-forks" => "stulentsev/resque-multi-job-forks",
        representable:               "trailblazer/representable",
        rr:                          "rr/rr",
        SassyLists:                  "at-import/SassyLists",
        :"Sassy-Maps"             => "at-import/Sassy-Maps",
        :"sassy-math"             => "at-import/Sassy-math",
        settingslogic:               "settingslogic/settingslogic",
        sinatra:                     "sinatra/sinatra",
        stripe:                      "stripe/stripe-ruby",
        thread_safe:                 "ruby-concurrency/thread_safe",
        tolk:                        "tolk/tolk",
        toolkit:                     "at-import/tookit",
        :"twitter-text"           => "twitter/twitter-text",
        zeus:                        "burke/zeus",
      }

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
        return spec.homepage if spec.homepage =~ GITHUB_REPO_REGEX
        match = spec.description.match(GITHUB_REPO_REGEX)
        match && match[0]
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

      def octokit_client
        Octokit::Client.new
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
