# frozen_string_literal: true

require "test_helper"

describe ".github_url" do
  it "returns github url from local gemspec" do
    Gemdiff::RepoFinder.stubs find_local_gemspec: fake_gemspec("homepage: http://github.com/rails/arel")
    assert_equal "https://github.com/rails/arel", Gemdiff::RepoFinder.github_url("arel")
  end

  it "strips anchors from urls" do
    Gemdiff::RepoFinder.stubs \
      find_local_gemspec: fake_gemspec("homepage: https://github.com/rubysec/bundler-audit#readme")
    assert_equal "https://github.com/rubysec/bundler-audit",
                 Gemdiff::RepoFinder.github_url("bundler-audit")
  end

  it "returns github url from remote gemspec" do
    Gemdiff::RepoFinder.stubs find_local_gemspec: ""
    Gemdiff::RepoFinder.stubs find_remote_gemspec: fake_gemspec("homepage: http://github.com/rails/arel")
    assert_equal "https://github.com/rails/arel", Gemdiff::RepoFinder.github_url("arel")
  end

  it "returns nil when gem does not exist and not found in search" do
    Gemdiff::RepoFinder.stubs octokit_client: mock_octokit(nil)
    Gemdiff::RepoFinder.stubs gemspec: ""
    assert_nil Gemdiff::RepoFinder.github_url("nope")
  end

  it "returns url from github search when gem does not exist and found in search" do
    Gemdiff::RepoFinder.stubs octokit_client: mock_octokit("x/x")
    Gemdiff::RepoFinder.stubs gemspec: ""
    assert_equal "https://github.com/x/x", Gemdiff::RepoFinder.github_url("x")
  end

  it "returns url from github search when not in gemspec" do
    Gemdiff::RepoFinder.stubs octokit_client: mock_octokit("y/y")
    Gemdiff::RepoFinder.stubs gemspec: fake_gemspec
    assert_equal "https://github.com/y/y", Gemdiff::RepoFinder.github_url("y")
  end

  it "returns nil when not in gemspec and not found" do
    Gemdiff::RepoFinder.stubs octokit_client: mock_octokit(nil)
    Gemdiff::RepoFinder.stubs gemspec: fake_gemspec
    assert_nil Gemdiff::RepoFinder.github_url("not_found")
  end

  it "returns exception url" do
    assert_equal "https://github.com/rails/rails", Gemdiff::RepoFinder.github_url("activerecord")
  end

  it "returns nil for gemspec with no homepage and no description" do
    Gemdiff::RepoFinder.stubs octokit_client: mock_octokit(nil)
    Gemdiff::RepoFinder.stubs gemspec: NO_DESCRIPTION_GEMSPEC
    assert_nil Gemdiff::RepoFinder.github_url("none")
  end

  it "returns url when # is present in description" do
    Gemdiff::RepoFinder.stubs find_local_gemspec: ANCHOR_DESCRIPTION_GEMSPEC
    assert_equal "https://github.com/nicksieger/multipart-post",
                 Gemdiff::RepoFinder.github_url("multipart-post")
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

FAKE_GEMSPEC = <<~SPEC
  --- !ruby/object:Gem::Specification
  name: fake
  version: !ruby/object:Gem::Version
    version: 1.2.3
  date: 2021-01-06 00:00:00.000000000 Z
  description: fake
SPEC

NO_DESCRIPTION_GEMSPEC = <<~SPEC
  --- !ruby/object:Gem::Specification
  name: fake
  version: !ruby/object:Gem::Version
    version: 1.2.3
  description:
SPEC

ANCHOR_DESCRIPTION_GEMSPEC = <<~SPEC
  --- !ruby/object:Gem::Specification
  name: multipart-post
  version: !ruby/object:Gem::Version
    version: 2.0.0
  description: 'IO values that have #content_type, #original_filename,
    and #local_path will be posted as a binary file.'
  homepage: https://github.com/nicksieger/multipart-post
  licenses:
  - MIT
SPEC

def fake_gemspec(extra = "")
  [FAKE_GEMSPEC, extra].compact.join("\n")
end
