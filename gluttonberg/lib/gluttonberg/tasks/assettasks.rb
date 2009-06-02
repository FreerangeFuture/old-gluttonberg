namespace :slices do
  namespace :gluttonberg do 
    desc "Try and generate thumbnails for all assets"
    task :create_thumbnails => :merb_env do
      assets = Gluttonberg::Asset.all
      assets.each do |asset|
        p "thumb-nailing '#{asset.file_name}'"
        asset.generate_image_thumb
        asset.save
      end
    end

    desc "Rebuild AssetType information and reassociate with existing Assets"
    task :rebuild_asset_types => :merb_env do
      Gluttonberg::Library.rebuild
    end
    
  end
end