require 'test_helper'

module Gemdiff
  class CLITest < MiniTest::Spec
    before do
      @cli = CLI.new
    end

    describe "#find" do
      it "finds" do
        mock_gem "haml"
        @cli.expects(:puts).with("http://github.com/haml/haml")
        @cli.find "haml"
      end

      it "does not find" do
        mock_missing_gem
        @cli.expects(:puts).with("Could not find github repository for notfound.")
        @cli.find "notfound"
      end
    end

    describe "#open" do
      it "opens repo" do
        gem = mock_gem("haml")
        @cli.expects(:puts).with("http://github.com/haml/haml")
        gem.expects :open
        @cli.open "haml"
      end
    end

    describe "#releases" do
      it "opens releases page" do
        gem = mock_gem("haml")
        @cli.expects(:puts).with("http://github.com/haml/haml")
        gem.expects :releases
        @cli.releases "haml"
      end
    end

    describe "#commits" do
      it "opens commits page" do
        gem = mock_gem("haml")
        @cli.expects(:puts).with("http://github.com/haml/haml")
        gem.expects :commits
        @cli.commits "haml"
      end
    end

    describe "#compare" do
      it "opens compare view" do
        gem = mock_gem("haml")
        gem.expects(:set_versions).with({})
        gem.expects(:missing_versions?).returns(false)
        gem.expects(:compare_message).returns("compare message")
        @cli.expects(:puts).with("http://github.com/haml/haml")
        @cli.expects(:puts).with("compare message")
        gem.expects :compare
        @cli.compare "haml"
      end

      it "returns when the gem is not found" do
        mock_missing_gem
        @cli.expects(:puts).with("Could not find github repository for notfound.")
        @cli.compare "notfound"
      end
    end

    describe "#outdated" do
      it "compares outdated gems with responses of y" do
        @cli.outdated
      end

      it "skips outdated gems without responses of y" do

        @cli.outdated
      end
    end

    describe "#update" do
      before do
        mock_inspector = mock { stubs list: []}
        BundleInspector.stubs new: mock_inspector
      end

      it "updates the gem and returns with no response" do
        @cli.stubs ask: ''
        @cli.update "haml"
      end

      it "updates, commits with responses of c" do
        @cli.stubs ask: 'r'
        @cli.update "haml"
      end

      it "updates, resets with responses of r" do
        @cli.stubs ask: 'r'
        @cli.update "haml"
      end
    end

  private

    def mock_gem(name)
      gem = mock do
        stubs repo?: true
        stubs repo: "http://github.com/#{name}/#{name}"
      end
      OutdatedGem.stubs new: gem
      gem
    end

    def mock_missing_gem
      gem = mock { stubs repo?: false }
      OutdatedGem.stubs new: gem
      gem
    end
  end
end
