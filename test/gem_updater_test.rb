require "test_helper"

class GemUpdaterTest < MiniTest::Spec
  describe "#update" do
    it "updates the gem" do
      updater = Gemdiff::GemUpdater.new("x")
      updater.expects :bundle_update
      updater.update
    end
  end

  describe "#commit" do
    it "adds a git commit for a gem update" do
      updater = Gemdiff::GemUpdater.new("json")
      updater.stubs git_removed_line: "-    json (1.8.0)"
      updater.stubs git_added_line: "+    json (1.8.1)"
      assert_equal "Update json to 1.8.1\n\nhttps://github.com/flori/json/compare/v1.8.0...v1.8.1",
                   updater.send(:commit_message)
      updater.expects :git_add_and_commit_lockfile
      assert updater.commit
    end

    it "adds a git commit for an update from a specific ref" do
      updater = Gemdiff::GemUpdater.new("ffi")
      updater.stubs git_removed_line: "-    ffi (1.2.3)"
      updater.stubs git_added_line: "+    ffi (1.2.4)\n+  ffi"
      assert_equal "Update ffi to 1.2.4\n\nhttps://github.com/ffi/ffi/compare/1.2.3...1.2.4",
                   updater.send(:commit_message)
      updater.expects :git_add_and_commit_lockfile
      assert updater.commit
    end

    it "adds a git commit for an update with dependencies" do
      updater = Gemdiff::GemUpdater.new("activejob")
      updater.stubs git_removed_line: "-    activejob (4.2.2)"
      updater.stubs git_added_line: \
        "+      activejob (= 4.2.3)\n+    activejob (4.2.3)\n+      activejob (= 4.2.3)"
      assert_equal "Update activejob to 4.2.3\n\nhttps://github.com/rails/rails/compare/v4.2.2...v4.2.3",
                   updater.send(:commit_message)
      updater.expects :git_add_and_commit_lockfile
      assert updater.commit
    end
  end

  describe "#reset" do
    it "resets Gemfile.lock" do
      updater = Gemdiff::GemUpdater.new("x")
      updater.expects :git_reset
      updater.reset
    end
  end

  describe "#diff" do
    it "returns git diff" do
      updater = Gemdiff::GemUpdater.new("x")
      updater.expects :git_diff
      updater.diff
    end
  end

  describe "#show" do
    it "returns git show" do
      updater = Gemdiff::GemUpdater.new("x")
      updater.expects :git_show
      updater.show
    end
  end

  describe "#clean?" do
    it "returns true for empty diff" do
      updater = Gemdiff::GemUpdater.new("x")
      updater.stubs git_diff: ""
      assert updater.clean?
    end

    it "returns false for non-empty diff" do
      updater = Gemdiff::GemUpdater.new("x")
      updater.stubs git_diff: "something"
      refute updater.clean?
    end
  end
end
