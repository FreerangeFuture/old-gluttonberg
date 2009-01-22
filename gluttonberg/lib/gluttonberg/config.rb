require Pathname(__FILE__).dirname.expand_path / "config" / "locale"

module Gluttonberg
  module Config
    def self.locales(&blk)
      Locale.class_eval(&blk)
    end
  end
end
