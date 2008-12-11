module Gluttonberg
  module PublicController
    def self.included(klass)
      klass.class_eval do
        attr_accessor :page, :dialect, :locale, :path, :page_template, :page_layout
        self._template_roots << [Gluttonberg::Templates.root, :_template_location]
        before :store_models_and_templates
        before :find_pages
        @@_before_filters.each {|f| before(*f) }
        @@_after_filters.each {|f| after(*f) }
      end
    end
    
    private
    
    def find_pages
      @pages = Page.all_with_localization(:parent_id => nil, :dialect => params[:dialect], :locale => params[:locale], :order => [:position.asc])
    end
    
    def store_models_and_templates
      @dialect  = params[:dialect]
      @locale   = params[:locale]
      @page     = params[:page]
      # Store the templates
      templates       = @page.template_paths(:dialect => params[:dialect], :locale => params[:locale])
      @page_template  = "pages/" + templates[:page] if templates[:page]
      @page_layout    = "#{templates[:layout]}.#{content_type}" if templates[:layout]
    end
    
    @@_before_filters = []
    @@_after_filters = []
    
    # Add a method to be called before each action
    def self.before(*args)
      @@_before_filters << args
    end
    
    # Add a method to be called after each action
    def self.after(*args)
      @@_after_filters << args
    end
  end
end