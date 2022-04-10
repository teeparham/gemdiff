# frozen_string_literal: true

module Gemdiff
  class BundleInspector
    BUNDLE_OUTDATED_PARSE_REGEX = /\A([^\s]+)\s\(newest\s([^,]+),\sinstalled\s([^,\)]+).*\z/.freeze

    def list
      @list ||=
        outdated
          .split("\n")
          .map { |line| new_outdated_gem(line) }
          .compact
    end

    def outdated
      @outdated ||= bundle_outdated_strict
    end

    def get(gem_name)
      list.detect { |gem| gem.name == gem_name }
    end

    private

    def bundle_outdated_strict
      `bundle outdated --strict --parseable`
    end

    def new_outdated_gem(line)
      return unless match = BUNDLE_OUTDATED_PARSE_REGEX.match(line)

      OutdatedGem.new(match[1], match[2], match[3])
    end
  end
end
