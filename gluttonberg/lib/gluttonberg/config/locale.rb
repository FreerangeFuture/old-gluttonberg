module Gluttonberg
  module Config
    class Locale
      @@default = nil
      @@locales = {}
      @@lookup  = Hash.new {|h,k| h[k] = {}}
      
      def self.locale(name, &blk)
        Locale.new(name, &blk)
      end
      
      def self.all(location = nil, dialect = nil)
        @@locales
      end

      def self.get(location, dialect)
        @@lookup[location][dialect]
      end
      
      def self.[](key)
        @@locales[key]
      end
      
      def self.default
        @@default
      end
      
      def initialize(name, &blk)
        # Set up the locale
        @default = false
        @options = {:location => {}, :dialect => {:code => "en", :name => "English"}}
        @options[:name] = name
        instance_eval(&blk)
        
        # Store it for retrieval later
        @@locales[name] = self
        # This collection is used to do a look up of locations based on location 
        # and dialect codes.
        @@lookup[self[:location][:code]][self[:dialect][:code]] = self
      end
      
      def [](key)
        @options[key]
      end
      
      def default?
        @default
      end
      
      def location(code, name, translation = nil)
        @options[:location][:code] = code.to_s
        @options[:location][:name] = name
        @options[:location][:translation] = translation if translation
      end
      
      def dialect(code, name, translation = nil)
        @options[:dialect][:code] = code.to_s
        @options[:dialect][:name] = name
        @options[:dialect][:translation] = translation if translation
      end
      
      def default(bool)
        @default = bool
        @@default = self if bool
      end
    end
  end
end
