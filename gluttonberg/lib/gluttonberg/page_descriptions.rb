module Gluttonberg
  # This module exposes a number of methods 
  module PageDescriptions
    @@page_descriptions = {}
    # The core of the description DSL. Passing a block to this method will
    # allow you to generate page descriptions
    def self.describe(&blk)
      class_eval(&blk)
    end
    
    # Returns the specified page description
    def self.[](name)
      @@page_descriptions[:name]
    end
    
    # Returns an array of the description classes
    def self.descriptions
      @@page_descriptions
    end
    
    # Removes any existing page descriptions
    def self.clear
      @page_descriptions.clear
    end
    
    private 
    
    def self.page(name, &blk)
      @@page_descriptions[:name] = Description.new(name, &blk)
    end
    
    class Description
      OPTIONS = [:label, :desc, :limit, :template, :layout, :rewrite]
      attr_reader :name, :sections, :options
      
      def initialize(new_name, &blk)
        @options = {:limit => :infinite, :template => "default", :layout => "default"}
        @sections = {}
        @name = new_name
        
        instance_eval(&blk)
      end
      
      def [](opt)
        @options[opt]
      end
      
      OPTIONS.each do |opt|
        class_eval %{
          def #{opt}(new_value)
            @options[:#{opt}] = new_value
          end
        }
      end
      
      private
      
      def section(name, opts)
        @sections[name] = Section.new(name, opts)
      end
    end
    
    class Section
      OPTIONS = [:label, :desc, :content, :count]
      attr_reader :name, :content_options, :options
      
      def initialize(name, opts)
        @name = name
        @options = {}
        OPTIONS.each {|o| @options[o] = opts.delete(o)}
        @content_options = opts
      end
      
      def [](opt)
        @options[opt]
      end
    end
  end
end
