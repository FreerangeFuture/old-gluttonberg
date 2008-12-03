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
  end
end