# frozen_string_literal: true

module Gemdiff
  class BundleInspector
    def list
      @list ||= outdated.split("\n").map { |line| new_outdated_gem(line) }.compact
    end

    def outdated
      @outdated ||= bundle_outdated_strict
    end

    def get(gem_name)
      list.detect { |gem| gem.name == gem_name }
    end

    private

    def bundle_outdated_strict
      `bundle outdated --strict`
    end

    def new_outdated_gem(line)
      return unless line.start_with?("  * ")

      # clean & convert new & old output to same format
      items = line.gsub("*", "")
                  .gsub("(newest", "")
                  .gsub(", installed", " >")
                  .gsub(/([(),])/, "")
                  .split(" ")

      # ["haml", "4.0.5", ">", "4.0.4"]
      # ["a_forked_gem", "0.7.0", "99ddbc9", ">", "0.7.0", "1da2295"]

      return if items[3] == ">" # skip non-gems for now
      OutdatedGem.new(items[0], items[3], items[1])
    end
  end
end
