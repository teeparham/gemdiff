require "test_helper"

class CLITest < MiniTest::Spec
  let(:cli) { Gemdiff::CLI.new }

  describe "#find" do
    it "finds" do
      mock_gem "haml"
      cli.expects(:puts).with("http://github.com/haml/haml")
      cli.find "haml"
    end

    it "does not find" do
      mock_missing_gem
      cli.expects(:puts).with("Could not find github repository for notfound.")
      cli.find "notfound"
    end
  end

  describe "#open" do
    it "opens repo" do
      outdated_gem = mock_gem("haml")
      cli.expects(:puts).with("http://github.com/haml/haml")
      outdated_gem.expects :open
      cli.open "haml"
    end
  end

  describe "#releases" do
    it "opens releases page" do
      outdated_gem = mock_gem("haml")
      cli.expects(:puts).with("http://github.com/haml/haml")
      outdated_gem.expects :releases
      cli.releases "haml"
    end
  end

  describe "#master" do
    it "opens commits page" do
      outdated_gem = mock_gem("haml")
      cli.expects(:puts).with("http://github.com/haml/haml")
      outdated_gem.expects :master
      cli.master "haml"
    end
  end

  describe "#compare" do
    it "opens compare view using bundle" do
      outdated_gem = mock_gem("haml")
      cli.expects(:puts).with("http://github.com/haml/haml")
      outdated_gem.expects(:set_versions).with(nil, nil)
      outdated_gem.expects(:missing_versions?).returns(true)
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      outdated_gem.expects(:load_bundle_versions).returns(true)
      outdated_gem.expects(:compare_message).returns("compare message")
      cli.expects(:puts).with("compare message")
      outdated_gem.expects :compare
      cli.compare "haml"
    end

    it "opens compare view with versions" do
      outdated_gem = mock_gem("haml")
      cli.expects(:puts).with("http://github.com/haml/haml")
      outdated_gem.expects(:set_versions).with("4.0.4", "4.0.5")
      outdated_gem.expects(:missing_versions?).returns(false)
      outdated_gem.expects(:compare_message).returns("compare message")
      cli.expects(:puts).with("compare message")
      outdated_gem.expects :compare
      cli.compare "haml", "4.0.4", "4.0.5"
    end

    it "returns when the gem is not found" do
      mock_missing_gem
      cli.expects(:puts).with("Could not find github repository for notfound.")
      cli.compare "notfound"
    end
  end

  describe "#outdated" do
    it "does nothing when nothing to update" do
      mock_inspector = mock do
        stubs list: []
        stubs outdated: ""
      end
      Gemdiff::BundleInspector.stubs new: mock_inspector
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      cli.expects(:puts).with("")
      cli.outdated
    end

    it "compares outdated gems with responses of y" do
      outdated_gem = Gemdiff::OutdatedGem.new("haml", "4.0.4", "4.0.5")
      mock_inspector = mock do
        stubs list: [outdated_gem]
        stubs outdated: "outdated"
      end
      Gemdiff::BundleInspector.stubs new: mock_inspector
      cli.stubs ask: "y"
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      cli.expects(:puts).with("outdated")
      cli.expects(:puts).with("haml: 4.0.5 > 4.0.4")
      outdated_gem.expects :compare
      cli.outdated
    end

    it "show compare urls of outdated gems with responses of s" do
      outdated_gem = Gemdiff::OutdatedGem.new("haml", "4.0.4", "4.0.5")
      mock_inspector = mock do
        stubs list: [outdated_gem]
        stubs outdated: "outdated"
      end
      Gemdiff::BundleInspector.stubs new: mock_inspector
      cli.stubs ask: "s"
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      cli.expects(:puts).with("outdated")
      cli.expects(:puts).with("haml: 4.0.5 > 4.0.4")
      outdated_gem.expects(:compare_url).returns("https://github.com/haml/haml/compare/4.0.4...4.0.5")
      cli.expects(:puts).with("https://github.com/haml/haml/compare/4.0.4...4.0.5")
      cli.outdated
    end

    it "skips outdated gems without responses of y" do
      outdated_gem = Gemdiff::OutdatedGem.new("haml", "4.0.4", "4.0.5")
      mock_inspector = mock do
        stubs list: [outdated_gem]
        stubs outdated: "outdated"
      end
      Gemdiff::BundleInspector.stubs new: mock_inspector
      cli.stubs ask: ""
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      cli.expects(:puts).with("outdated")
      cli.expects(:puts).with("haml: 4.0.5 > 4.0.4")
      outdated_gem.expects(:compare).never
      cli.outdated
    end
  end

  describe "#list" do
    it "does nothing when nothing to update" do
      mock_inspector = mock do
        stubs list: []
        stubs outdated: ""
      end
      Gemdiff::BundleInspector.stubs new: mock_inspector
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      cli.expects(:puts).with("")
      cli.expects(:puts).with("\n")
      cli.list
    end

    it "lists outdated gems" do
      outdated_gem = Gemdiff::OutdatedGem.new("pundit", "1.0.0", "1.0.1")
      mock_inspector = mock do
        stubs list: [outdated_gem]
        stubs outdated: "outdated"
      end
      Gemdiff::BundleInspector.stubs new: mock_inspector
      outdated_gem.expects(:compare_url).returns("https://github.com/elabs/pundit/compare/v1.0.0...v1.0.1")
      cli.expects(:puts).with(Gemdiff::CLI::CHECKING_FOR_OUTDATED)
      cli.expects(:puts).with("outdated")
      cli.expects(:puts).with("\n").twice
      cli.expects(:puts).with("pundit: 1.0.1 > 1.0.0")
      cli.expects(:puts).with("https://github.com/elabs/pundit/compare/v1.0.0...v1.0.1")
      cli.list
    end
  end

  describe "#update" do
    before do
      @mock_gem = mock do
        stubs clean?: true
        stubs diff: "le diff"
        stubs show: "le show"
      end
      Gemdiff::GemUpdater.stubs new: @mock_gem
    end

    it "updates the gem and returns with no response" do
      cli.stubs ask: ""
      cli.expects(:puts).with("Updating haml...")
      @mock_gem.expects :update
      cli.expects(:puts).with("le diff")
      cli.update "haml"
    end

    it "updates the gem and commits with responses of c" do
      cli.stubs ask: "c"
      cli.expects(:puts).with("Updating haml...")
      @mock_gem.expects :update
      cli.expects(:puts).with("le diff")
      @mock_gem.expects :commit
      cli.expects(:puts).with("\nle show")
      cli.update "haml"
    end

    it "updates the gem and resets with responses of r" do
      cli.stubs ask: "r"
      cli.expects(:puts).with("Updating haml...")
      @mock_gem.expects :update
      cli.expects(:puts).with("le diff")
      @mock_gem.expects(:reset).returns("le reset")
      cli.expects(:puts).with("le reset")
      cli.update "haml"
    end
  end

  private

  def mock_gem(name)
    outdated_gem = mock do
      stubs repo?: true
      stubs repo: "http://github.com/#{name}/#{name}"
    end
    Gemdiff::OutdatedGem.stubs new: outdated_gem
    outdated_gem
  end

  def mock_missing_gem
    outdated_gem = mock { stubs repo?: false }
    Gemdiff::OutdatedGem.stubs new: outdated_gem
    outdated_gem
  end
end
