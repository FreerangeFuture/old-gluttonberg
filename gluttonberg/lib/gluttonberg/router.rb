module Gluttonberg
  module Router
    # Set up the many and various routes for Gluttonberg
    def self.setup(scope)
      # Login/Logout
      scope.match("/login", :method => :get ).to(:controller => "/exceptions", :action => "unauthenticated").name(:login)
      scope.match("/login", :method => :put ).to(:controller => "sessions", :action => "update").name(:perform_login)
      scope.match("/logout").to(:controller => "sessions", :action => "destroy").name(:logout)
      
      # The admin dashboard
      scope.match("/").to(:controller => "main").name(:admin_root)
      
      scope.identify DataMapper::Resource => :id do |s|
        # Controllers in the content module
        s.match("/content").to(:controller => "content/main").name(:content)
        s.match("/content") do |c|
          c.resources(:pages, :controller => "content/pages") do |p|
            p.resources(:localizations, :controller => "content/page_localizations")
          end
          c.match("/pages/move(.:format)").to(:controller => "content/pages", :action => "move_node").name(:page_move)
        end
        
        # Asset Library
        s.match("/library").to(:controller => "library/main").name(:library)
        s.match("/library") do |a|
          a.match("/assets").to(:controller => "library/assets") do |as|
            as.match("/browser").to(:action => "browser").name(:asset_browser)
            as.match("/browse/:category(/by-:order)(/:page)(.:format)", :category => /[a-zA-Z]/, :order => /[a-zA-Z]/, :page => /\d+/).
              to(:action => "category").name(:asset_category)
          end
          a.resources(:assets, :controller => "library/assets")
          a.resources(:collections, :controller => "library/collections")          
          a.match("/collections/:id/add_asset").to(:controller => "library/collections", :action => "add_asset").name(:add_asset_to_collection)
          a.match("/collections/:id(/by-:order)(/:page)(.:format)").to(:controller => "library/collections", :action => "show").name(:collection_show)
     #     a.resources(:asset_types, :controller => "library/asset_types")
     #     a.resources(:asset_categories, :controller => "library/asset_categories")
     #     a.resources(:asset_mime_types, :controller => "library/asset_mime_types")
        end
      
        # Settings
        s.match("/settings").to(:controller => "settings/main").name(:settings)
        s.match("/settings") do |se|
          se.resources(:locales, :controller => "settings/locales")
          se.resources(:dialects, :controller => "settings/dialects")
          se.resources(:users, :controller => "settings/users")
        end
        
        # Help
        s.match("/help/:module_and_controller/:page", :module_and_controller => %r{\S+}).to(:controller => "help", :action => "show").name(:help)
        
        s.gluttonberg_public_routes(:prefix => "public") if Gluttonberg.standalone?
      end
    end
    
    # TODO: look at matching a root, which people might hit without 
    # selecting a locale or dialect
    PUBLIC_DEFER_PROC = lambda do |request, params|
      params[:full_path] = "" unless params[:full_path]
      additional_params, conditions = Gluttonberg::Router.localization_details(params)
      page = Gluttonberg::Page.first_with_localization(conditions.merge(:path => params[:full_path]))
      if page
        case page.description[:behaviour]
          when :rewrite
            Gluttonberg::Router.rewrite(page, params[:full_path], request, params, additional_params)
          when :redirect
            redirect(page.description.redirect_url(page, params))
          else
            {
              :controller => params[:controller], 
              :action     => params[:action], 
              :page       => page, 
              :format     => params[:format]
            }.merge!(additional_params)
        end
      else
        # TODO: The string concatenation here is Sqlite specific, we need to 
        # handle it differently per adapter.
        names = PageDescription.names_for(:rewrite)
        component_conditions = conditions.merge(
          "page.description_name" => names,
          :conditions             => ["? LIKE (path || '%')", params[:full_path]], 
          :order                  => [:path.asc]
        )
        page = Gluttonberg::Page.first_with_localization(component_conditions)
        if page
          Gluttonberg::Router.rewrite(page, params[:full_path], request, params, additional_params)
        else
          raise Merb::ControllerExceptions::NotFound
        end
      end
    end
    
    def self.localization_details(params)
      # check to see if we're localized, translated etc, then build the 
      # conditions and the additional params with the locale/dialect stuffed
      # into them. Also should include the full_path
      additional_params = {}
      conditions = {}
      # Get the locale, falling back to a default
      opts = if Gluttonberg.localized?
        {:slug => params[:locale]}
      else
        {:default => true}
      end
      locale = Gluttonberg::Locale.first(opts)
      raise Merb::ControllerExceptions::NotFound unless locale
      additional_params[:locale] = locale
      conditions[:locale_id] = locale.id
      # Get the dialect, falling back to a default
      dialect = if Gluttonberg.translated?
        cascade_to_dialect(
          Gluttonberg::Dialect.all(:conditions => ["? LIKE code || '%'", params[:dialect]]),
          params[:dialect]
        )
      else
        Gluttonberg::Dialect.first(:default => true)
      end
      raise Merb::ControllerExceptions::NotFound unless dialect
      additional_params[:dialect] = dialect
      conditions[:dialect_id] = dialect.id
      
      additional_params[:original_path] = params[:full_path]
      # If it's all good just return them both
      [additional_params, conditions]
    end
    
    def self.cascade_to_dialect(dialects, requested_dialect)
      # If the dialects are empty, just return the default straight away.
      #
      # If we have dialects in our DB, let's try to find a match. If we don't
      # have any matches, lets reduce the request lang and recurse until we find 
      # a match or need to return the default.
      if dialects.nil?
        dialects.first(:default => true)
      else
        match = dialects.pluck {|d| d.code == requested_dialect}
        if match
          match
        else
          index = requested_dialect.rindex("-")
          if index
            cascade_to_dialect(dialects, requested_dialect[0, index])
          else
            dialects.first(:default => true)
          end
        end
      end
    end
    
    def self.rewrite(page, original_path, request, params, additional_params)
      additional_params[:page] = page
      additional_params[:format] = params[:format]
      rewrite_path = Merb::Router.url(page.description.rewrite_route)
      request.env["REQUEST_PATH"] = original_path.gsub(page.current_localization.path, rewrite_path)
      new_params = Merb::Router.match(request)[1]
      new_params.merge(additional_params)
    end
    
    def self.localized_url(path, params)
      opts, named_route = if path == "/"
        [{}, :root]
      else
        [{:full_path => path}, :page]
      end
      if ::Gluttonberg.localized_and_translated?
        opts.merge!(:locale => params[:locale].slug, :dialect => params[:dialect].code)
      elsif ::Gluttonberg.localized?
        opts.merge!(:locale => params[:locale].slug)
      elsif ::Gluttonberg.translated?
        opts.merge!(:dialect => params[:dialect].code)
      end
      Merb::Router.url((Gluttonberg.standalone? ? :"gluttonberg_public_#{named_route}" : :"public_#{named_route}"), opts)
    end
    
    Merb::Router.extensions do
      def gluttonberg_public_routes(opts = {})
        Merb.logger.info("Adding Gluttonberg's public routes")


        # Only generate DragTree routes if we are NOT running as a standalone slice
        # users of DragTree within the slice need to explicitly set the route!
        # these need to be before the more generic routes added below
        Gluttonberg::DragTree::RouteHelpers.build_drag_tree_routes(self) unless Gluttonberg.standalone?

        # See if we need to add the prefix
        path = opts[:prefix] ? "/#{opts[:prefix]}/" : "/"
        # Check to see if this is localized or translated and if either need to
        # be added as a URL prefix. For now we just assume it's going into the
        # URL.
        if Gluttonberg.localized_and_translated?
          path << ":locale/:dialect"
        elsif Gluttonberg.localized?
          path << ":locale"
        elsif Gluttonberg.translated?
          path << ":dialect"
        end
        
        # Build the full path, which includes the format. This needs to account
        # for the simple case where we match from "/"
        full_path = if Gluttonberg.localized? || Gluttonberg.translated?
          path + "/:full_path(.:format)"
        else
          path + ":full_path(.:format)"
        end

        controller = Gluttonberg.standalone? ? "content/public" : "gluttonberg/content/public"
        # Set up the defer to block
        match(path + "/:full_path(.:format)", :full_path => /[a-z0-9\-_\/]+/).defer_to(
          {:controller => controller, :action => "show"}, 
          &Gluttonberg::Router::PUBLIC_DEFER_PROC
        ).name(:public_page)
        # Filthy hack to match against the root, since the URL won't 
        # regenerate with optional parameters — :full_path
        match(path).defer_to({:controller => controller, :action => "show"}, &Gluttonberg::Router::PUBLIC_DEFER_PROC).name(:public_root)
      end
    end
  end
end