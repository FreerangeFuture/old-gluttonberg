module Gluttonberg
  class PageLocalization
    include DataMapper::Resource

    property :id,               Serial
    property :name,             String,   :length => 150
    property :navigation_label, String,   :length => 0..100
    property :slug,             String,   :length => 0..50
    property :path,             String,   :length => 255, :writer => :private
    property :locale_name,      String,   :length => 50
    property :created_at,       Time
    property :updated_at,       Time

    belongs_to :page

    after :save, :update_content_localizations

    attr_accessor :paths_need_recaching, :content_needs_saving

    # Returns the locale for this localization based on it's dialect and 
    # location codes.
    def locale
      Config::Locale[locale_name.to_sym]
    end
    
    # Returns the location for this localization based on the assigned locale.
    # Will return the translated version if passed the :translated symbol.
    def location_name(mode = :name)
      locale[:location][mode]
    end
    
    # Returns the dialect for this localization based on the assigned locale.
    # Will return the translated version if passed the :translated symbol.
    def dialect_name(mode = :name)
      locale[:dialect][mode]
    end

    # Write an explicit setter for the slug so we can check it’s not a blank 
    # value. This stops it being overwritten with an empty string.
    def slug=(new_slug)
      attribute_set(:slug, new_slug) unless new_slug.blank?
    end

    # Returns an array of content localizations
    def contents
      @contents ||= begin
        # First collect the localized content
        contents = Gluttonberg::Content.localization_associations.inject([]) do |memo, assoc|
          memo += send(assoc).all
        end
        # Then grab the content that belongs directly to the page
        Gluttonberg::Content.non_localized_associations.inject(contents) do |memo, assoc|
          contents += page.send(assoc).all
        end
      end
    end
    
    # Updates each localized content record and checks their validity
    def contents=(params)
      self.content_needs_saving = true
      contents.each do |content|
        update = params[content.association_name][content.id.to_s]
        content.attributes = update if update
      end
      #all_valid?
    end

    def paths_need_recaching?
      @paths_need_recaching
    end

    def name_and_code
      "#{name} (#{locale[:location][:name]}/#{locale[:dialect][:code]})"
    end
    
    # Forces the localization to regenerate it's full path. It will firstly
    # look to see if there is a parent page that it need to derive the path
    # prefix from. Otherwise it will just use the slug, with a fall-back
    # to it's page's default.
    def regenerate_path
      if page.parent_id
        localization = page.parent.localizations.first(
          :fields           => [:path],
          :locale_id        => locale_id, 
          :dialect_id       => dialect_id
        )
        path = "#{localization.path}/#{slug || page.slug}"
      else
        path = "#{slug || page.slug}"
      end
      attribute_set(:path, path)
    end
    
    # Regenerates and saves the path to this localization.
    def regenerate_path!
      regenerate_path
      save
    end
    
    private
    
    def update_content_localizations
      contents.each { |c| c.save } if self.content_needs_saving
    end
  end
end