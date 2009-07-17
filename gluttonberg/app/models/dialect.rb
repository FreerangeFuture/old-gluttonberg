module Gluttonberg
  class Dialect
    include DataMapper::Resource
    include Gluttonberg::Authorizable

    property :id,       Integer,  :serial   => true,  :key => true
    property :code,     String,   :length   => 2..15, :nullable => false
    property :name,     String,   :length   => 1..70, :nullable => false
    property :default,  Boolean,  :default  => false

    has n, :page_localizations, :class_name => "Gluttonberg::PageLocalization"
    has n, :locales, :through => Resource, :class_name => "Gluttonberg::Locale"

    # Returns a formatted string with both the name and the ISO code for this
    # localization
    def name_and_code
      "#{name} (#{code})"
    end
    
    def  self.first_default(opts={})
      opts[:default] = true
      first(opts)
    end  
  end
end