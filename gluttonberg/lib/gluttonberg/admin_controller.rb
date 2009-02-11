module Gluttonberg
  module AdminController
    def self.included(klass)
      klass.class_eval do
        self._template_roots << [Gluttonberg.root / "app" / "views", :_template_location]
        layout("gluttonberg")
        before :ensure_authenticated
      end
    end
    
    # This is to be called from within a controller — i.e. the delete action — 
    # and it will display a dialog which allows users to either confirm 
    # deleting a record or cancelling the action.
    def display_delete_confirmation(opts)
      @options = opts
      @options[:title]    ||= "Delete Record?"
      @options[:message]  ||= "If you delete this record, it will be gone permanently. There is no undo."
      render :template => "shared/delete", :layout => false
    end
    
    # A helper for finding shortcutting the steps in finding a model ensuring
    # it has a localization and raising a NotFound if it’s missing.
    def with_localization(model, id)
      result = model.first_with_localization(localization_ids.merge(:id => id))
      raise NotFound unless result
      result.ensure_localization!
      result
    end
    
    # Returns a hash with the locale and dialect ids extracted from the params
    # or where they're missing, it will grab the defaults.
    def localization_ids
      @localization_opts ||= begin
        if params[:localization]
          ids = params[:localization].split("-")
          {:locale => ids[0], :dialect => ids[1]}
        else
          dialect = Gluttonberg::Dialect.first(:default => true)
          locale = Gluttonberg::Locale.first(:default => true)
          # Inject the ids into the params so our form fields behave
          params[:localization] = "#{locale.id}-#{dialect.id}"
          {:locale => locale.id, :dialect => dialect.id}
        end
      end
    end
    
    # Returns an array containing the current page, total page count and 
    # the results
    class Paginator
      attr_reader :current, :total
      def initialize(current, total)
        @current  = current
        @total    = total
      end
      
      def previous?
        @current > 1
      end
      
      def next?
        @current < @total
      end
      
      def previous
        @current > 1 ? @current - 1 : 1
      end
      
      def next
        @current < @total ? @current + 1 : @total
      end
    end
    
    def paginate(model_or_association_proxy, opts = {})
      if params[:page]
        page = params[:page].to_i 
        opts[:page] = page
      else
        page = 1
      end
      results = model_or_association_proxy.send(:paginated, opts)
      [Paginator.new(page, results[0]), results[1]]
    end
  end
end