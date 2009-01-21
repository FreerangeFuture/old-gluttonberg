module Gluttonberg
  class Page
    include DataMapper::Resource

    property :id,               Integer,  :serial => true, :key => true
    property :parent_id,        Integer
    property :name,             String,   :length => 1..100
    property :navigation_label, String,   :length => 0..100
    property :slug,             String,   :length => 1..100
    property :description_name, String,   :length => 1..100
    property :home,             Boolean,  :default => false,  :writer => :private
    property :created_at,       Time
    property :updated_at,       Time

    before :valid?, :slug_management
    after  :save,   :check_for_home_update

    is_drag_tree :scope => [:parent_id], :flat => false

    has n,      :localizations,       :class_name => "Gluttonberg::PageLocalization"
    has n,      :children,            :class_name => "Gluttonberg::Page", :child_key => [:parent_id], :order => [:position.asc]
    belongs_to  :passthrough_target,  :class_name => "Gluttonberg::Page"

    attr_accessor :current_localization, :dialect_id, :locale_id, :paths_need_recaching
    
    # Returns the localized navigation label, or falls back to the page for a
    # the default.
    def nav_label
      if current_localization.navigation_label.blank?
        if navigation_label.blank?
          name
        else
          navigation_label
        end
      else
        current_localization.navigation_label
      end
    end

    # Returns the localized title for the page or a default
    def title
      current_localization.name.blank? ? attribute_get(:name) : current_localization.name
    end
    
    # Delegates to the current_localization
    def path
      current_localization.path
    end

    # Returns the PageDescription associated with this page.
    def description
      @description = PageDescription[description_name.to_sym] if description_name
    end
    
    # Returns the name of the view template specified for this page —
    # determined via the associated PageDescription
    def view
      @description[:view] if @description
    end
    
    # Returns the name of the layout template specified for this page —
    # determined via the associated PageDescription
    def layout
      @description[:layout] if @description
    end

    # Returns a hash containing the paths to the page and layout templates.
    def template_paths(opts = {})
      {
        :page => Gluttonberg::Templates.template_for(:pages, view, opts), 
        :layout => Gluttonberg::Templates.template_for(:layout, layout, opts)
      }
    end

    def slug=(new_slug)
      #if you're changing this regex, make sure to change the one in /javascripts/slug_management.js too
      new_slug = new_slug.downcase.gsub(/\s/, '_').gsub(/[\!\*'"″′‟‛„‚”“”˝\(\)\;\:\@\&\=\+\$\,\/?\%\#\[\]]/, '')
      attribute_set(:slug, new_slug)
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    # Just palms off the request for the contents to the current localization
    def localized_contents
      @contents ||= begin
        Content.content_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all_with_localization(:page_localization_id => current_localization.id)
        end
      end
    end

    # This finder grabs the matching page and under the hood also grabs the 
    # relevant localization.
    #
    # FIXME: The way errors are raised here is ver nasty, needs fixing up 
    def self.first_with_localization(options)
      if options[:path] == ""
        options.delete(:path)
        page = Page.first(:home => true)
        return nil unless page
        localization = page.localizations.first(options)
        return nil unless localization
      else
        localization = PageLocalization.first(options)
        return nil unless localization
        page = localization.page
      end
      page.current_localization = localization
      page
    end
    
    # Returns the matching pages with their specified localizations preloaded
    def self.all_with_localization(conditions)
      l_conditions = extract_localization_conditions(conditions)
      all(conditions).each {|p| p.load_localization(l_conditions)}
    end

    # Returns the immediate children of this page, which the specified
    # localization preloaded.
    # TODO: Have this actually check the current mode
    def children_with_localization(conditions)
      l_conditions = self.class.extract_localization_conditions(conditions)
      children.all(conditions).each { |c| c.load_localization(l_conditions)}
    end
    
    # Load the matching localization as specified in the options
    def load_localization(conditions = {})
      # OMGWTFBBQ: I shouldn't have explicitly set the id in the conditions
      # like this, since I’m going through an association.
      conditions[:page_id] = id 
      @current_localization = localizations.first(conditions) unless conditions.empty?
    end

    def home=(state)
      attribute_set(:home, state)
      @home_updated = state
    end

    private

    def slug_management
      @slug = name if @slug.blank?
    end

    # Checks to see if this page has been set as the homepage. If it has, we 
    # then go and 
    def check_for_home_update
      if @home_updated && @home_updated == true
        previous_home = Page.first(:home => true, :id.not => id)
        previous_home.update_attributes(:home => false) if previous_home
      end
    end
    
    private
    
    def self.extract_localization_conditions(opts)
      conditions = [:dialect, :locale].inject({}) do |memo, opt|
        memo[:"#{opt}_id"] = opts.delete(opt).id if opts[opt]
        memo
      end
    end
  end
  
end