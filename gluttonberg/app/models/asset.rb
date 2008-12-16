module Gluttonberg
  class Asset
    include DataMapper::Resource
    include Library::AttachmentMixin
    
    property :id,         Serial 
    property :category,   Enum[*Library::CATEGORIES]
    property :type,       Enum[*Library::TYPES]
    property :mime_type,  String
    property :localized,  Boolean, :default => false
    property :created_at, Time
    property :updated_at, Time

    has n, :localizations, :class_name => "Gluttonberg::AssetLocalization"
    has n, :collections, :through => Resource, :class_name => "Gluttonberg::AssetCollection"

    belongs_to  :asset_type, :class_name => "Gluttonberg::AssetType"

    # This replaces the existing set of associated collections with a new set based
    # on the array of IDs passed in.
    def collection_ids=(new_ids)
      # This is slightly crude, but lets just delete the join models that we
      # don't need anymore.

      # NOTE: Datamapper will try to insert rows into the join table on a Many to Many
      # even if the relationship is already defined.
      # You need to clear the relationships and reinsert them to prevent composite key
      # violation errors

      #self.gluttonberg_asset_gluttonberg_asset_collections.all(:asset_collection_id.not => new_ids).destroy!
      clear_all_collections
      self.collections = Gluttonberg::AssetCollection.all(:id => new_ids)
    end

    def clear_all_collections
      self.gluttonberg_asset_gluttonberg_asset_collections.all.destroy! unless self.new_record?
    end

    # These are for temporarily storing values to be inserted into a 
    # localization. They are only used when the asset is first created or
    # when it's in non-localize-mode.
    attr_accessor :locale_id, :dialect_id
    
    after   :save,    :update_file
    before  :valid?,  :set_category_and_type
    
    def localized?
      localized
    end
    
    def full_type
      attribute_get(:type) ? "#{attribute_get(:type)} #{category}" : category
    end
    
    def type
      attribute_get(:type) ? attribute_get(:type) : category
    end

    def auto_set_asset_type
      self.asset_type = AssetType.for_file(mime_type, file_name)
    end

    def self.refresh_all_asset_types
      all.each do |asset|
        asset.auto_set_asset_type
        asset.save
      end
    end

    def self.clear_all_asset_types
      all.each do |asset|
        asset.asset_type = nil
        asset.save
      end
    end
    
    private
    
    def set_category_and_type
      unless file.nil?
        attribute_set(:mime_type, file[:content_type])

        Library.santise_mime_type(mime_type, file_name)

        p '************** MIME TYPE ********************'
        p mime_type
        p '*********************************************'

        # Determine the category based on the matchers specified in the library
        category_set = false
        Library::CATEGORY_PATTERNS.each do |t, m|
          attribute_set(:category, t) if mime_type.match(m)
          category_set = true
        end
        unless category_set
          attribute_set(:category, Library::UNCATEGORISED_CATEGORY)
        end

        p '************** CATEGORY ********************'
        p category
        p '*********************************************'

        # Now slightly more complicated; check the extension, then mime type to
        # try and determine the exact asset type.
        #
        # See if it has an extension
        # If it has, check it against the list inside the patterns
        # If it doesn't, use the regex patterns to examine the mime-type
        # If none match, mark it as generic
        attribute_set(:type, Library::UNKNOWN_TYPE)
        match = file[:filename].match(%r{\.([a-zA-Z]{2,6})$})
        if match && match[1]
          Library::TYPE_PATTERNS.each do |type, values|
            attribute_set(:type, type) if values.include?(match[1].downcase)
          end
        else
          Library::TYPE_PATTERNS.each do |type, values|
            attribute_set(:type, type) if mime_type.match(values.last)
          end
        end

        p '************** TYPE ********************'
        p type
        p '*********************************************'

        auto_set_asset_type
      end
    end
    
    def update_file
      if localized? and new_record?
        AssetLocalization.create(
          :asset        => self, 
          :locale_id    => locale_id,
          :dialect_id   => dialect_id,
          :name         => name,
          :description  => description,
          :file         => file
        )
      else
        update_file_on_disk
      end
    end


  end
end
