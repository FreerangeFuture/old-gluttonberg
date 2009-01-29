module Gluttonberg
  module Content
    module TextFilters
      @@filters = {}
      
      def self.all
        @@filters.values
      end
      
      def self.get(name)
        @@filters[name.to_sym]
      end
      
      def self.register(name, klass)
        @@filters[name.to_sym] = klass
      end
      
      module PartMixin
        def is_text_filter(name)
          Gluttonberg::Content::TextFilters.register(name, self)
        end
      end
      
      module Helpers
        # This replaces each instance of our {{}} syntax with the results of 
        # calling a matching filter. The notation breaks down as class/action/id
        #
        #   {{movies/summary/3}}
        #
        def filter_text(text)
          if text
            text.gsub(%r{(<p>)?\{\{\S+\}\}(</p>)?}) do |match|
              extract = match.match(/(\w+)\/(\w+)\/(\w+)/)
              klass = Gluttonberg::Content::TextFilters.get(extract[1])
              # Now actually call the part. It's return value will be used as the 
              # replacement text in the gsub.
              part klass => extract[2].to_sym, :id => extract[3]
            end
          end
        end
      end
      
    end #TextFilters
  end # Content
end # Gluttonberg

# Mix our modules into the global helpers and the part controller
Merb::GlobalHelpers.send(:include, Gluttonberg::Content::TextFilters::Helpers)
Merb::PartController.send(:extend, Gluttonberg::Content::TextFilters::PartMixin)
