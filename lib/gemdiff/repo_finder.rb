require 'octokit'

module Gemdiff
  module RepoFinder
    GITHUB_REPO_REGEX = /(https?):\/\/(www.)?github\.com\/([\w._%-]*)\/([\w._%-]*)/

    # rails builds several gems that are not individual projects
    # some repos move and the old repo page still exists
    # some repos are not mostly ruby so the github search doesn't find them
    REPO_EXCEPTIONS =
      {
        actionmailer:                'rails/rails',
        actionpack:                  'rails/rails',
        actionview:                  'rails/rails',
        activemodel:                 'rails/rails',
        activerecord:                'rails/rails',
        activesupport:               'rails/rails',
        color:                       'halostatue/color',
        delayed_job:                 'collectiveidea/delayed_job',
        gosu:                        'jlnr/gosu',
        nokogiri:                    'sparklemotion/nokogiri',
        passenger:                   'phusion/passenger',
        railties:                    'rails/rails',
        resque:                      'resque/resque',
        :"resque-multi-job-forks" => 'stulentsev/resque-multi-job-forks',
        sinatra:                     'sinatra/sinatra',
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
        return nil unless (spec = gemspec(gem_name))
        match = spec.match(GITHUB_REPO_REGEX)
        match && match[0]
      end

      def search(gem_name)
        query = "#{gem_name} language:ruby in:name"
        result = octokit_client.search_repositories(query)
        return nil if result.items.empty?
        github_repo result.items.first.full_name
      end

      def github_repo(full_name)
        "http://github.com/#{full_name}"
      end

      def octokit_client
        Octokit::Client.new
      end

      def gemspec(name)
        local = find_local_gemspec(name)
        return find_remote_gemspec(name) unless last_shell_command_success?
        local if local =~ GITHUB_REPO_REGEX
      end

      def last_shell_command_success?
        $?.success?
      end

      def find_local_gemspec(name)
        `gem spec #{name}`
      end

      def find_remote_gemspec(name)
        `gem spec -r #{name}`
      end
    end
  end
end
