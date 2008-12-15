module Gluttonberg
  class AssetCategory
    include DataMapper::Resource
  
    property :id, Serial

    property :name, String

    has n, :asset_categories
  end
end
