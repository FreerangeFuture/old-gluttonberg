if defined?(Merb::Plugins)

  merb_version = ">= 1.0"
  merb_parts_version = ">= 0.9.8"
  datamapper_version = ">= 0.9.6"
  
  # Require everything relative to this file.
  $:.unshift File.dirname(__FILE__)

  load_dependency 'merb-slices', merb_version
  Merb::Plugins.add_rakefiles "gluttonberg/tasks/merbtasks", "gluttonberg/tasks/slicetasks"
  Merb::Plugins.add_rakefiles "gluttonberg/tasks/assettasks", "gluttonberg/tasks/dragtreetasks", "gluttonberg/tasks/pagetasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Default configuration. This can be modified by users in an application’s 
  # init.rb inside of the before_app_loads block.
  #
  # Merb::BootLoader.before_app_loads do
  #   Merb::Slices::config[:gluttonberg][:localize] = false
  # end
  Merb::Slices::config[:gluttonberg] = {
    :layout         => :gluttonberg,
    :localize       => true,
    :translate      => true,
    :encode_dialect => :url,
    :encode_locale  => :url,
    :template_dir   => Merb.root / "templates"
  }.merge!(Merb::Slices::config[:gluttonberg])
  
  module Gluttonberg
    self.description = "A content management system"
    self.version = "0.0.4"
    self.author = "Freerange Future (www.freerangefuture.com)"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
      Helpers.setup
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader. This is where we 
    # keep the majority of the code needed for bootstrapping the slice.
    def self.activate
      # Have to re-add the HTML mime-type again to ensure that it gets it's 
      # proper weighting, otherwise it seems our :htmlf format is swiping it.
      Merb.add_mime_type(:htmlf, :to_htmlf, %w(text/html application/xhtml+xml), {}, 0.1)
      Merb.add_mime_type(:html, :to_html, %w(text/html application/xhtml+xml), {}, 1)
      
      # Call set up on the various components inside of Gluttonberg. If you’re 
      # not sure where some configuration or defaults are being set, these 
      # modules are the first place to look.
      PageDescription.setup
      Content.setup
      Library.setup
      Templates.setup

      # 
      Merb::Authentication.user_class = Gluttonberg::User
      Merb::Authentication.activate!(:default_password_form)
      Merb::Plugins.config[:"merb-auth"][:login_param] = "email"
      Merb::Authentication.class_eval do 
        def store_user(user)
          return nil unless user 
          user.id
        end
        def fetch_user(session_info)
          User.get(session_info)
        end
      end
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(Gluttonberg)
    def self.deactivate
    end
    
    # The actual routing setup is palmed off to our Router module. This is 
    # purely because it’s so big and nasty, it’d just clutter up this file.
    def self.setup_router(scope)
      Gluttonberg::Router.setup(scope)
    end
    
    # Checks to see if Gluttonberg has been configured to have a locale/location
    # and a translation.
    def self.localized_and_translated?
      config[:localize] && config[:translate]
    end
   
    # Check to see if Gluttonberg is configured to be localized.
    def self.localized?
      config[:localize]
    end
    
    # Check to see if Gluttonberg has been configured to translate contents.
    def self.translated?
      config[:translate]
    end
  end
  
  # Auto-load models. This isn’t supported in merb-slices by default.
  Gluttonberg.push_path(:models, Gluttonberg.root / "app" / "models")
  
  # Don’t require the observers in tests. They interfere with the fixture
  # generation.
  unless Merb.environment == 'test'
    Gluttonberg.push_path(:observers, Gluttonberg.root / "app" / "observers")
  end
  
  # Default directory layout
  Gluttonberg.setup_default_structure!
  
  # Third party dependencies
  dependency 'merb-assets',     merb_version
  dependency 'merb-helpers',    merb_version
  dependency 'merb_datamapper', merb_version
  dependency 'dm-aggregates',   datamapper_version
  dependency 'dm-is-tree',      datamapper_version
  dependency 'dm-observer',     datamapper_version
  dependency 'dm-is-list',      datamapper_version
  dependency 'dm-validations',  datamapper_version
  dependency 'dm-timestamps',   datamapper_version
  dependency 'dm-types',        datamapper_version
  dependency 'merb-auth-core',  merb_version
  dependency 'merb-parts',      merb_parts_version
  dependency 'merb-auth-more',  merb_version do
    require 'merb-auth-more/mixins/redirect_back'
  end
  dependency 'RedCloth',        ">= 4.1.0",  {:require_as => 'redcloth'} do
    require "gluttonberg/redcloth_helper"
    require "gluttonberg/red_cloth_partials"
  end
  dependency 'mime-types', '>= 1.15',  {:require_as => 'mime/types'}
  
  # Stdlib dependencies
  require 'digest/sha1'

  # The various mixins and classses that make up Gluttonberg.
  require "gluttonberg/content"
  require "gluttonberg/library"
  require "gluttonberg/router"
  require "gluttonberg/extensions"
  require "gluttonberg/admin_controller"
  require "gluttonberg/public_controller"
  require "gluttonberg/templates"
  require "gluttonberg/components"
  require "gluttonberg/helpers"
  require "gluttonberg/page_description"
  require "gluttonberg/drag_tree_helper"
  require "gluttonberg/authorizable"
  
end
