helpers = Pathname(__FILE__).dirname.expand_path / "helpers"
require helpers / "content"
require helpers / "assets"
require helpers / "public"
require helpers / "admin"

module Gluttonberg
  # A whole heaping helping of helpers for both the administration back-end and
  # the public views.
  module Helpers
    # Mixes all the helpers into the GlobalHelpers module. Slighly messy, but
    # hey it works.
    def self.setup
      [Assets, Admin, Public, Content].each do |helper|
        Merb::GlobalHelpers.send(:include, helper)
      end
    end
  end
end
