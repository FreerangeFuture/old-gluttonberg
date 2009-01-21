module Gluttonberg
  module Content
    module Localization
      def self.included(klass)
        klass.class_eval do
          extend  Model::ClassMethods
          include Model::InstanceMethods
          
          class << self; attr_reader :localized, :localized_model; end
          attr_reader :current_localization
          @localized = false
        end
      end
      
      # This module gets mixed into the class that includes the localization module
      module Model
        module ClassMethods
          def is_localized(&blk)
            # Why yes, this is localized.
            @localized = true

            # Create the localization model
            class_name = self.name + "Localization"
            table_name = Extlib::Inflection.tableize(class_name)
            # Check to see if the localization is inside a constant
            target = Kernel
            if class_name.index("::")
              modules = class_name.split("::")
              # Remove the localization class from the end
              class_name = modules.pop
              # Get each constant in turn
              modules.each { |mod| target = target.const_get(mod) }
            end
            @localized_model = target.const_set(class_name, DataMapper::Model.new(table_name))
            
            # Add the properties declared in the block, and sprinkle in our own mixins
            @localized_model.class_eval(&blk)
            @localized_model.send(:include, ModelLocalization)
            
            # Set up filters on the class to make sure the localization gets migrated
            self.after_class_method(:auto_migrate!) { @localized_model.auto_migrate! }
            self.after_class_method(:auto_upgrade!) { @localized_model.auto_upgrade! }
            
            # Associate the model and it’s localization
            has(n, :localizations, :class_name => self.name + "Localization")
            @localized_model.belongs_to(:parent, :class_name => self.name, :child_key => [:parent_id])
          end
          
          def localized?
            @localized
          end
          
          def all_with_localization(opts)
            localization_opts = {:dialect_id => opts.delete(:dialect), :locale_id => opts.delete(:locale)}
            matches = all(opts)
            matches.each { |match| match.load_localization(localization_opts) }
            matches
          end
          
          def first_with_localization(opts)
            localization_opts = {:dialect_id => opts.delete(:dialect), :locale_id => opts.delete(:locale)}
            match = first(opts)
            match.load_localization(localization_opts)
            match
          end
        end
        
        module InstanceMethods
          def localized?
            self.class.is_localized?
          end
          
          def load_localization(opts)
            # Convert keys into ids if they are not already
            opts.each { |key, value| opts[key] = value.id unless value.is_a? Numeric }
            # Inject additional conditions, since DataMapper isn't scoping on 
            # collections correctly.
            opts[:parent_id] = self.id
            # Go and find the localization
            @current_localization = self.class.localized_model.first(opts)
          end
        end
      end
      
      # This module is used when dynamically creating the localization class.
      module ModelLocalization
        # This included hook is used to declare base properties like the id and 
        # to set up associations to the dialect and locale
        def self.included(klass)
          klass.class_eval do
            property :id,         DataMapper::Types::Serial
            property :created_at, Time
            property :updated_at, Time
            
            belongs_to :dialect,  :class_name => "Gluttonberg::Dialect"
            belongs_to :locale,   :class_name => "Gluttonberg::Locale"
          end
        end
        
        
      end
    end # Localization
  end # Content
end # Gluttonberg
