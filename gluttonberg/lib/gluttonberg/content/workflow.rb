module Gluttonberg
  module Content
    module Workflow
      
      def self.included(klass)
        
        klass.class_eval do
	    property :state,  DataMapper::Types::Enum[:in_progress, :pending, :rejected , :approved], :default => :in_progress
	    extend ClassMethods
	    include InstanceMethods
	end
        
      end

      module ClassMethods
        
	  def all_pending(options = {})
	    options[:state] = :pending
            all(options)
	  end
          
	  def all_rejected(options = {})
	    options[:state] = :rejected
	    all(options)
	  end
          
          def all_approved_and_published(options = {})
            options.merge!( :state => :approved , :published => true )          
            all(options)  
          end
      end

      module InstanceMethods
	  
	  def submit!
              update_attributes(:state=>:pending)
	  end
          
	  def approve!
              update_attributes(:state=>:approved)
	  end
          
	  def reject!
              update_attributes(:state=>:rejected)
	  end
      end


    end
  end
end