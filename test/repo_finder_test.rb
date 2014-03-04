require 'test_helper'

module Gemdiff
  class RepoFinderTest < MiniTest::Spec
    describe ".github_url" do
      it "returns github url from gemspec" do
        RepoFinder.stubs find_homepage_in_spec: "homepage: http://github.com/rails/arel"
        assert_equal "http://github.com/rails/arel", RepoFinder.github_url("arel")
      end

      it "returns github url from github search" do
        RepoFinder.stubs octokit_client: mock_octokit("haml/haml")
        RepoFinder.stubs find_homepage_in_spec: ""
        assert_equal "http://github.com/haml/haml", RepoFinder.github_url("haml")
      end

      it "returns nil when not found" do
        RepoFinder.stubs octokit_client: mock_octokit(nil)
        RepoFinder.stubs find_homepage_in_spec: ""
        assert_nil RepoFinder.github_url("not_found")
      end

      it "returns exception url" do
        assert_equal "http://github.com/rails/rails", RepoFinder.github_url('activerecord')
      end
    end

  private

    def mock_octokit(full_name)
      mock_items = if full_name.nil?
                     mock { stubs items: [] }
                   else
                     mock_item = mock { stubs full_name: full_name }
                     mock { stubs items: [mock_item] }
                   end
      mock { stubs search_repositories: mock_items }
    end
  end
end
