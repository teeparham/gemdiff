require "test_helper"

class RepoFinderTest < MiniTest::Spec
  describe ".github_url" do
    it "returns github url from local gemspec" do
      Gemdiff::RepoFinder.stubs find_local_gemspec: fake_gemspec("homepage: http://github.com/rails/arel")
      Gemdiff::RepoFinder.stubs last_shell_command_success?: true
      assert_equal "http://github.com/rails/arel", Gemdiff::RepoFinder.github_url("arel")
    end

    it "strips anchors from urls" do
      Gemdiff::RepoFinder.stubs \
        find_local_gemspec: fake_gemspec("homepage: https://github.com/rubysec/bundler-audit#readme")
      Gemdiff::RepoFinder.stubs last_shell_command_success?: true
      assert_equal "https://github.com/rubysec/bundler-audit",
                   Gemdiff::RepoFinder.github_url("bundler-audit")
    end

    it "returns github url from remote gemspec" do
      Gemdiff::RepoFinder.stubs find_local_gemspec: ""
      Gemdiff::RepoFinder.stubs last_shell_command_success?: false
      Gemdiff::RepoFinder.stubs find_remote_gemspec: fake_gemspec("homepage: http://github.com/rails/arel")
      assert_equal "http://github.com/rails/arel", Gemdiff::RepoFinder.github_url("arel")
    end

    it "returns github url from github search" do
      Gemdiff::RepoFinder.stubs octokit_client: mock_octokit("haml/haml")
      Gemdiff::RepoFinder.stubs gemspec: fake_gemspec
      assert_equal "https://github.com/haml/haml", Gemdiff::RepoFinder.github_url("haml")
    end

    it "returns nil when not found" do
      Gemdiff::RepoFinder.stubs octokit_client: mock_octokit(nil)
      Gemdiff::RepoFinder.stubs gemspec: fake_gemspec
      assert_nil Gemdiff::RepoFinder.github_url("not_found")
    end

    it "returns exception url" do
      assert_equal "https://github.com/rails/rails", Gemdiff::RepoFinder.github_url("activerecord")
    end
  end

  private

  def mock_octokit(full_name)
    mock_items = if full_name.nil?
                   stub items: []
                 else
                   stub items: [stub(full_name: full_name)]
                 end
    stub search_repositories: mock_items
  end

FAKE_GEMSPEC = %(
--- !ruby/object:Gem::Specification
name: fake
version: !ruby/object:Gem::Version
  version: 1.2.3
description: fake
)

  def fake_gemspec(extra = "")
    [FAKE_GEMSPEC, extra].compact.join("\n")
  end
end
