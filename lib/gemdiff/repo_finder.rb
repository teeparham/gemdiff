require 'octokit'

module Gemdiff
  module RepoFinder
    GITHUB_REPO_REGEX = /(https?):\/\/(www.)?github\.com\/([\w._%-]*)\/([\w._%-]*)/

    # rails builds several gems that are not individual projects
    # some repos move and the old repo page still exists
    REPO_EXCEPTIONS =
      {
        actionmailer:  'rails/rails',
        actionpack:    'rails/rails',
        actionview:    'rails/rails',
        activemodel:   'rails/rails',
        activerecord:  'rails/rails',
        activesupport: 'rails/rails',
        railties:      'rails/rails',
        resque:        'resque/resque',
      }

    class << self
      # Try to get the homepage from the gemspec
      # If not found, search github
      def github_url(gem_name)
        homepage = gemspec_homepage(gem_name)
        return homepage if homepage
        search gem_name
      end

    private

      def gemspec_homepage(gem_name)
        if (full_name = REPO_EXCEPTIONS[gem_name.to_sym])
          return github_repo(full_name)
        end
        homepage = find_homepage_in_spec(gem_name)
        match = homepage.match(GITHUB_REPO_REGEX)
        match && match[0]
      end

      def search(gem_name)
        query = "#{gem_name}&language:ruby&in:name"
        result = octokit_client.search_repositories(query)
        return nil if result.items.empty?
        result.items
        github_repo result.items.first.full_name
      end

      def github_repo(full_name)
        "http://github.com/#{full_name}"
      end
      
      def octokit_client
        Octokit::Client.new
      end

      def find_homepage_in_spec(gem_name)
        `gem spec #{gem_name} | grep //github.com/`
      end
    end
  end
end
