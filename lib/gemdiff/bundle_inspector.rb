module Gemdiff
  class BundleInspector
    def list
      @list ||= begin
        gems = []
        outdated.split("\n").each do |line|
          next unless (outdated_gem = new_outdated_gem(line))
          gems << outdated_gem
        end
        gems
      end
    end

    def outdated
      @outdated ||= bundle_outdated_strict
    end

    def get(gem_name)
      list.select{ |gem| gem.name == gem_name }.first
    end

  private

    def bundle_outdated_strict
      `bundle outdated --strict`
    end

    def new_outdated_gem(line)
      return nil unless line.start_with?('  * ')
      items = line.split(' ')

      # ["*", "haml", "(4.0.5", ">", "4.0.4)"]
      # ["*", "a_forked_gem", "(0.7.0", "99ddbc9", ">", "0.7.0", "1da2295)"]

      return nil if items[4] == '>' # skip non-gems for now
      old_version = items[4].sub(')', '')
      new_version = items[2].sub('(', '')
      OutdatedGem.new(items[1], old_version, new_version)
    end
  end
end
