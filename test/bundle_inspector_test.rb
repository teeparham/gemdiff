require 'test_helper'

module Gemdiff
  class BundleInspectorTest < MiniTest::Spec
    describe "#list" do
      it "returns outdated gems" do
        inspector = BundleInspector.new
        inspector.stubs bundle_outdated_strict: fake_outdated
        inspector.list.tap do |list|
          assert_equal 2, list.size
          assert_equal 'aws-sdk', list[0].name
          assert_equal '1.34.1', list[0].old_version
          assert_equal '1.35.0', list[0].new_version
          assert_equal 'haml', list[1].name
          assert_equal '4.0.4', list[1].old_version
          assert_equal '4.0.5', list[1].new_version
        end
      end

      it "returns empty list when bundle is up to date" do
        inspector = BundleInspector.new
        inspector.stubs bundle_outdated_strict: fake_up_to_date
        assert_empty inspector.list
      end
    end

    describe "#get" do
      it "returns single outdated gem" do
        inspector = BundleInspector.new
        inspector.stubs bundle_outdated_strict: fake_outdated
        inspector.get('haml').tap do |gem|
          assert_equal 'haml', gem.name
          assert_equal '4.0.4', gem.old_version
          assert_equal '4.0.5', gem.new_version
        end
      end

      it "returns nil when gem is not outdated" do
        inspector = BundleInspector.new
        inspector.stubs bundle_outdated_strict: fake_up_to_date
        assert_nil inspector.get('notfound')
      end
    end

  private

    def fake_outdated
<<OUT
Updating git://github.com/neighborland/active-something.git
Fetching gem metadata from https://rubygems.org/.......
Fetching additional metadata from https://rubygems.org/..
Resolving dependencies...

Outdated gems included in the bundle:
  * active-something (0.7.0 99ddbc9 > 0.7.0 1da2295)
  * aws-sdk (1.35.0 > 1.34.1)
  * haml (4.0.5 > 4.0.4)
OUT
  end

  def fake_up_to_date
<<OUT
Fetching gem metadata from https://rubygems.org/.........
Fetching additional metadata from https://rubygems.org/..
Resolving dependencies...

Your bundle is up to date!
OUT
    end
  end
end
