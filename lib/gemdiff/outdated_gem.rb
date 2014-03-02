module Gemdiff
  class OutdatedGem
    attr_accessor :name, :old_version, :new_version

    def initialize(name, old_version, new_version)
      @name = name
      @old_version = old_version
      @new_version = new_version
    end
  end
end
