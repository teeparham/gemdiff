require 'test_helper'

module Gemdiff
  class GemUpdaterTest < MiniTest::Spec
    describe "#update" do
      it "updates the gem" do
        updater = GemUpdater.new("x")
        updater.expects :bundle_update
        updater.update
      end
    end

    describe "#commit" do
      it "adds a git commit for a gem update" do
        updater = GemUpdater.new("aws-sdk")
        updater.stubs git_changed_line: "+    aws-sdk (1.35.0)"
        updater.expects(:git_add_and_commit_lockfile).with("1.35.0")
        assert updater.commit
      end
    end

    describe "#reset" do
      it "resets Gemfile.lock" do
        updater = GemUpdater.new("x")
        updater.expects :git_reset
        updater.reset
      end
    end

    describe "#diff" do
      it "returns git diff" do
        updater = GemUpdater.new("x")
        updater.expects :git_diff
        updater.diff
      end
    end

    describe "#show" do
      it "returns git show" do
        updater = GemUpdater.new("x")
        updater.expects :git_show
        updater.show
      end
    end

    describe "#clean?" do
      it "returns true for empty diff" do
        updater = GemUpdater.new("x")
        updater.stubs git_diff: ""
        assert updater.clean?
      end

      it "returns false for non-empty diff" do
        updater = GemUpdater.new("x")
        updater.stubs git_diff: "something"
        refute updater.clean?
      end
    end

  end
end
