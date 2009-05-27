module Gluttonberg
  module Content
    module Publishable
      
      def self.included(klass)
        klass.class_eval do
	    property :published,  DataMapper::Types::Boolean, :default => false
	    extend ClassMethods
	    include InstanceMethods
	end
      end

      module ClassMethods
	  def published(options = {})
	    options[:published] = true
            first(options)
	  end
	  def all_published(options = {})
	    options[:published] = true
	    all(options)
	  end
      end

      module InstanceMethods
	  
	  def publish!
              update_attributes(:published=>true)
	  end
	  def unpublish!
              update_attributes(:published=>false)
	  end
	  def published?
              @published
	  end
      end


    end
  end
end