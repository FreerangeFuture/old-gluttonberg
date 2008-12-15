module Gluttonberg
  class AssetType
    include DataMapper::Resource
  
    property :id, Serial

    property :name, String
    property :mime_type, String

    has n, :assets
    belongs_to  :asset_category, :class_name => "Gluttonberg::AssetCategory"

  end
end
