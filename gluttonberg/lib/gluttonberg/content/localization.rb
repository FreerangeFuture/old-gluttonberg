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
            has(n, :localizations, :class_name => self.name + "Localization", :parent_key => [:id], :child_key => [:parent_id])
            @localized_model.belongs_to(:parent, :class_name => self.name, :parent_key => [:parent_key], :child_key => [:id])
            
            # Set up validations for when we update in the presence of a localization
            after :valid?, :validate_current_localization
          end
          
          def localized?
            @localized
          end
          
          # Returns a new instance of the model, with a localization instance 
          # already assigned to it based on the options passed in.
          #
          # The options may also include the attributes for the new model. To 
          # specify attributes for the localized instance, you can pass them in
          # via an entry with the key :localized_attributes, e.g.
          #
          #   {:name => "spong", :localized_attributes => {:name =>"le spong"}}
          def new_with_localization(opts)
            localization_opts = extract_localization_opts(opts)
            new_model = new
            new_model.instance_variable_set(:@current_localization, @localized_model.new(localization_opts))
            new_model.localizations << new_model.current_localization
            new_model.attributes = opts
            new_model
          end
          
          def all_with_localization(opts)
            localization_opts = extract_localization_opts(opts)
            matches = all(opts)
            matches.each { |match| match.load_localization(localization_opts) }
            matches
          end
          
          def first_with_localization(opts)
            localization_opts = extract_localization_opts(opts)
            match = first(opts)
            if match
              match.load_localization(localization_opts)
              match
            end
          end
          
          private 
          
          def extract_localization_opts(opts)
            # Coerce each entry into an integer
            [:dialect, :locale].inject({}) do |m, n|
              m[:"#{n}_id"] = opts.delete(n).to_i if opts[n]
              m
            end
          end
          
          private 
          
          def extract_localization_opts(opts)
            # Coerce each entry into an integer
            [:dialect, :locale].inject({}) do |m, n|
              m[:"#{n}_id"] = opts.delete(n).to_i if opts[n]
              m
            end
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
            # Stash the opts so we can use em later
            @localization_opts = opts
            # Go and find the localization
            @current_localization = self.class.localized_model.first(opts)
          end
          
          def current_dialect
            current_localization.dialect if current_localization
          end
          
          def current_locale
            current_localization.locale if current_localization
          end
          
          # If the record doesn't have a localization, this will generate a new one
          def ensure_localization!
            unless @current_localization
              @current_localization = self.class.localized_model.new(@localization_opts)
            end
          end
          
          # Returns the current localization's attributes
          def localized_attributes
            current_localization.attributes if current_localization
          end
          
          # Assigns the hash of values passed in to the current localization's
          # attributes.
          def localized_attributes=(new_attributes)
            current_localization.attributes = new_attributes if current_localization
          end
          
          private
          
          # Validates the current_localization. If it is invalid, it's errors 
          # are appended to the model's own errors.
          def validate_current_localization
            if current_localization
              unless current_localization.valid?
                current_localization.errors.each { |name, error| errors.add(name, error) }
              end
            end
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
