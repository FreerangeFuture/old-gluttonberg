module Gluttonberg  
    # A mixin that will add simple authorization functionality to any arbitrary 
    # model. This includes finders for retrieving authorized records and 
    # instance methods for quickly changing the state.
    module Authorizable
      # Add the class and instance methods, declare the relationship we store the
      # published state in.
      def self.included(klass)
        klass.class_eval do
          extend ClassMethods
          include InstanceMethods
          
          belongs_to :user
        end
      end

      module ClassMethods
        
        def all_for_user(user , options = {})
          if user.is_super_admin
            all(options)
          else
            options[:user_id] = user.id
            all(options)
          end
        end  

        def get_for_user(user , id)
          options = {:id => id }
          if user.is_super_admin            
            first(options)
          else
            options[:user_id] = user.id
            first(options)
          end
        end  
      end  #ClassMethods

      module InstanceMethods
        
      end #InstanceMethods
      
    end # Authorizable  
end # Gluttonberg
