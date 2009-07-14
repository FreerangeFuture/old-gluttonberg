class Exceptions  < Merb::Controller
    #handle NotFound exceptions (404)
    def not_found
      render :layout => "bare"
    end

    # handle NotAcceptable exceptions (406)
    def not_acceptable
      render :layout => "bare"
    end
    def internal_server_error
      render :layout => "bare"
    end  
  end
module Gluttonberg
  

  # the mixin to provide the exceptions controller action for Unauthenticated  
  module ExceptionsMixin
    
    
    def unauthenticated
      provides :xml, :js, :json, :yaml

      case content_type
      when :html
        render :layout => "bare"
      else
        basic_authentication.request!
        ""
      end
    end # unauthenticated
  end
end  
  Merb::Authentication.customize_default do
  
    Exceptions.class_eval do
      include Merb::Slices::Support # Required to provide slice_url
  
      # # This stuff allows us to provide a default view
      the_view_path = File.expand_path(File.dirname(__FILE__) / ".." / "views")
      self._template_roots ||= []
      self._template_roots << [the_view_path, :_template_location]
      self._template_roots << [Merb.dir_for(:view), :_template_location]
    
      include Gluttonberg::ExceptionsMixin
    
      show_action :unauthenticated

    end# Exceptions.class_eval
  
  end # Customize default
#end