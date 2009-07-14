module Gluttonberg
  # This module allows custom controllers to be registered wtih Gluttonberg’s
  # administration. Typically, these controllers will be registered in the 
  # application’s before_app_loads block.
  module Components
    @@components  = {}
    @@routes      = {}
    @@nav_entries = nil
    @@registered  = nil
    Component     = Struct.new(:name, :label)
    
    # Registers a controller — or set of controllers — based on the URLs 
    # specified in the routes.
    #
    #   Components.register(:forum, :label => "Forum", :admin_url => url) do |scope|
    #     scope.resources(:posts)
    #     scope.resources(:threads)
    #   end
    def self.register(name, opts = {}, &routes)
      @@components[name] = opts
      @@routes[name] = routes if block_given?
    end
    
    # Returns a hash of the registered components, keyed to their label.
    def self.registered
      @@registered ||= @@components.collect {|k, v| Component.new(k.to_s, v[:label])}
    end
    
    # Returns an array of components that have been given a nav_label —
    # the label implicitly registers them as nav entries. Components without
    # a label won’t turn up.
    def self.nav_entries      
      @@nav_entries ||= @@components.collect do |k, v| 
        url = if v[:admin_url]
          if v[:admin_url].is_a? Symbol
            Merb::Router.url(v[:admin_url])
          else
            v[:admin_url]
          end
        end        
        [v[:label], k, url]
      end
    end
  end
end
