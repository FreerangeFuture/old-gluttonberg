module Gluttonberg
  class AssetCategory
    include DataMapper::Resource
  
    property :id, Serial

    property :name, String, :nullable => false
    property :unknown, Boolean, :default => false

    has n, :asset_types

    validates_is_unique :name

    def self.method_missing(methId, *args)
      method_info = methId.id2name.split('_')
      if method_info.length == 2 then
        if method_info[1] == 'category' then
          cat_name = method_info[0]
          if cat_name then
            return first(:name => cat_name)
          end
        end
      end
    end

    def self.build_defaults
      # Ensure the default categories exist in the database.
      ensure_exists('audio', false)
      ensure_exists('image', false)
      ensure_exists('video', false)
      ensure_exists('document', false)
      ensure_exists('archive',  false)
      ensure_exists('binary',   false)
      ensure_exists('uncategorised', true)
    end

    private

    def self.ensure_exists(name, unknown)
      cat = first(:name => name)
      if cat then
        cat.unknown = unknown
        cat.save
      else
        cat = new(:name => name, :unknown => unknown)
        cat.save
      end
    end
  end
end
