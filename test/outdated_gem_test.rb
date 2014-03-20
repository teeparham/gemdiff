require 'test_helper'

module Gemdiff
  class OutdatedGemTest < MiniTest::Spec
    describe "#missing_versions?" do
      it "returns true" do
        assert OutdatedGem.new("x").missing_versions?
      end

      it "returns false" do
        refute OutdatedGem.new("x", "1", "2").missing_versions?
      end
    end

    describe "#compare_url" do
      it "returns compare url" do
        gem = OutdatedGem.new("x", "1.0", "2.0")
        gem.stubs repo: "http://github.com/x/x"
        assert_equal "http://github.com/x/x/compare/v1.0...v2.0", gem.compare_url
      end

      it "returns compare url with no v for exceptions" do
        gem = OutdatedGem.new("haml", "4.0.0", "4.1.0")
        gem.stubs repo: "http://github.com/haml/haml"
        assert_equal "http://github.com/haml/haml/compare/4.0.0...4.1.0", gem.compare_url
      end

      it "returns compare url with branch name for new version" do
        gem = OutdatedGem.new("x", "4.0.0", "master")
        gem.stubs repo: "http://github.com/x/x"
        assert_equal "http://github.com/x/x/compare/v4.0.0...master", gem.compare_url
      end
    end

    describe "#releases_url" do
      it "returns releases url" do
        gem = OutdatedGem.new("x")
        gem.stubs repo: "http://github.com/x/x"
        assert_equal "http://github.com/x/x/releases", gem.releases_url
      end
    end

    describe "#commits_url" do
      it "returns commits url" do
        gem = OutdatedGem.new("x")
        gem.stubs repo: "http://github.com/x/x"
        assert_equal "http://github.com/x/x/commits/master", gem.commits_url
      end
    end

    describe "#compare_message" do
      it "returns compare message" do
        gem = OutdatedGem.new("x", "1", "2")
        gem.stubs repo: "http://github.com/x/x"
        assert_equal "x: 2 > 1", gem.compare_message
      end
    end

    describe "#load_bundle_versions" do
      it "returns false if not found" do
        mock_inspector = mock { stubs :get }
        BundleInspector.stubs new: mock_inspector
        refute OutdatedGem.new("x").load_bundle_versions
      end

      it "sets versions from gem in bundle" do
        mock_outdated_gem = OutdatedGem.new("y", "1.2.3", "2.3.4")
        mock_inspector = mock { stubs get: mock_outdated_gem }
        BundleInspector.stubs new: mock_inspector
        gem = OutdatedGem.new("y")
        assert gem.load_bundle_versions
        assert_equal "1.2.3", gem.old_version
        assert_equal "2.3.4", gem.new_version
      end
    end

    describe "#set_versions" do
      it "sets nil versions" do
        gem = OutdatedGem.new("x", "1", "2")
        gem.set_versions nil, nil
        assert_nil gem.old_version
        assert_nil gem.new_version
      end

      it "sets old, new versions" do
        gem = OutdatedGem.new("x")
        gem.set_versions "1.2.34", "2.34.56"
        assert_equal "1.2.34", gem.old_version
        assert_equal "2.34.56", gem.new_version
      end

      it "swaps versions in the wrong order" do
        gem = OutdatedGem.new("x")
        gem.set_versions "2.34.56", "1.2.34"
        assert_equal "1.2.34", gem.old_version
        assert_equal "2.34.56", gem.new_version
      end
    end

    describe "#master" do
      it "opens master commits url" do
        gem = OutdatedGem.new("x")
        gem.stubs repo: "http://github.com/x/x"
        gem.expects(:open_url).with("http://github.com/x/x/commits/master")
        gem.master
      end
    end

    describe "#releases" do
      it "opens releases url" do
        gem = OutdatedGem.new("x")
        gem.stubs repo: "http://github.com/x/x"
        gem.expects(:open_url).with("http://github.com/x/x/releases")
        gem.releases
      end
    end

    describe "#compare" do
      it "opens compare url" do
        gem = OutdatedGem.new("x", "1.2.3", "2.3.4")
        gem.stubs repo: "http://github.com/x/x"
        gem.expects(:open_url).with("http://github.com/x/x/compare/v1.2.3...v2.3.4")
        gem.compare
      end
    end

    describe "#open" do
      it "opens repo url" do
        gem = OutdatedGem.new("x")
        gem.stubs repo: "http://github.com/x/x"
        gem.expects(:open_url).with("http://github.com/x/x")
        gem.open
      end
    end
  end
end
