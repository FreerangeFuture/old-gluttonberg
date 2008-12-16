module Gluttonberg
  class AssetMimeType
    include DataMapper::Resource
  
    property :id, Serial

    property :mime_type, String

    belongs_to :asset_type, :class_name => "Gluttonberg::AssetType"

    validates_is_unique :mime_type
  end
end
