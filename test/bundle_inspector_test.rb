# frozen_string_literal: true

require "test_helper"

class BundleInspectorTest < MiniTest::Spec
  let(:inspector) { Gemdiff::BundleInspector.new }

  describe "#list" do
    it "returns outdated gems" do
      inspector.stubs bundle_outdated_strict: fake_outdated_parseable
      inspector.list.tap do |list|
        assert_equal 3, list.size
        assert_equal "paperclip", list[0].name
        assert_equal "4.2.2", list[0].old_version
        assert_equal "4.3.0", list[0].new_version
        assert_equal "rails", list[1].name
        assert_equal "4.2.1", list[1].old_version
        assert_equal "4.2.2", list[1].new_version
        assert_equal "web-console", list[2].name
        assert_equal "2.1.2", list[2].old_version
        assert_equal "2.1.3", list[2].new_version
      end
    end

    it "returns empty list when bundle is up to date" do
      inspector.stubs bundle_outdated_strict: fake_up_to_date
      assert_empty inspector.list
    end
  end

  describe "#get" do
    it "returns single outdated gem" do
      inspector.stubs bundle_outdated_strict: fake_outdated_parseable
      inspector.get("rails").tap do |gem|
        assert_equal "rails", gem.name
        assert_equal "4.2.1", gem.old_version
        assert_equal "4.2.2", gem.new_version
      end
    end

    it "returns nil when gem is not outdated" do
      inspector.stubs bundle_outdated_strict: fake_up_to_date
      assert_nil inspector.get("notfound")
    end
  end

  private

  def fake_outdated_parseable
    <<~OUT
      paperclip (newest 4.3.0, installed 4.2.2)
      rails (newest 4.2.2, installed 4.2.1, requested ~> 4.2.1)
      web-console (newest 2.1.3, installed 2.1.2)
    OUT
  end

  def fake_up_to_date
    <<~OUT

    OUT
  end
end
