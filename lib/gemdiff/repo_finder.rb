require 'octokit'

module Gemdiff
  module RepoFinder
    GITHUB_REPO_REGEX = /(https?):\/\/(www.)?github\.com\/([\w._%-]*)\/([\w._%-]*)/

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
        homepage = find_homepage_in_spec(gem_name)
        match = homepage.match(GITHUB_REPO_REGEX)
        match && match[0]
      end

      def search(gem_name)
        query = "#{gem_name}&language:ruby&in:name"
        result = octokit_client.search_repositories(query)
        return nil if result.items.empty?
        result.items
        "http://github.com/#{result.items.first.full_name}"
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
