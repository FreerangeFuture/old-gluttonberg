module Gluttonberg
  module Library
    module AttachmentMixin
      begin
        @@generate_thumbs = require 'image_science'
      rescue LoadError
        @@generate_thumbs = false
      end

      def self.included(klass)
        klass.class_eval do
          property :name,             String
          property :description,      DataMapper::Types::Text
          property :file_name,        String, :length => 255
          property :hash,             String, :length => 255, :writer => :private
          property :size,             Integer
          # if custom_thumbnail is false thumbs for the category will
          # be used. If true thumbs form the assets file location will
          # be used.
          property :custom_thumbnail, TrueClass, :default => false
          
          after   :destroy, :remove_file_from_disk
          before  :save,    :generate_reference_hash

          def self.generate_all_thumbnails
            assets = Gluttonberg::Asset.all
            assets.each do |asset|
              p "thumb-nailing '#{asset.file_name}'"
              asset.generate_image_thumb
              asset.save
            end
            'done' # this just makes the output nicer when running from slice -i
          end

        end
      end
      
      def file=(new_file)
        unless new_file.blank?
          # Forgive me this naive sanitisation, I'm still a regex n00b
          clean_filename = new_file[:filename].gsub(" ", "_").gsub(/[^A-Za-z0-9\-_.]/, "").downcase
          
          # _thumb.jpg is a reserved name for the thumbnailing system, so if the user
          # has a file with that name rename it.
          if (clean_filename == '_thumb_small.jpg') || (clean_filename == '_thumb_large.jpg')
            clean_filename = 'thumb.jpg'
          end
          
          attribute_set(:file_name, clean_filename)
          attribute_set(:size, new_file[:size])
          @file = new_file
        end
      end
      
      def file
        @file
      end
      
      def url
        "/assets/#{hash}/#{file_name}"
      end
        
      def thumb_small_url
        if custom_thumbnail
          "/assets/#{hash}/_thumb_small.jpg"
        else
          "/images/category/#{category}/_thumb_small.jpg"
        end
      end

      def thumb_large_url
        if custom_thumbnail
          "/assets/#{hash}/_thumb_large.jpg"
        else
          "/images/category/#{category}/_thumb_large.jpg"
        end
      end
      
      def location_on_disk
        directory / file_name
      end
      
      def directory
        Library.root / hash
      end

      def generate_thumb
        # first assign the default thumbs for the category
        # then spawn a worker to generate thumbs if possible and update
        asset_id_to_process = self.id
        run_later do
          asset = Asset.get(asset_id_to_process)
          if asset
            asset.generate_image_thumb
            asset.save!
          end
        end
      end

      def generate_image_thumb
        # raises a Type Error if not a supported image
        if @@generate_thumbs
          begin
            ImageScience.with_image(location_on_disk) do |img|
              # small = 110w x 75h
              # large = 250w x 200h

              if (img.height >= img.width) then
                # scale to height
                img.thumbnail(75) do |thumb|
                  thumb.save File.join(directory,'_thumb_small.jpg')
                end
                img.thumbnail(200) do |thumb|
                  thumb.save File.join(directory,'_thumb_large.jpg')
                end
              else
                # scale to width
                img.thumbnail(110) do |thumb|
                  thumb.save File.join(directory,'_thumb_small.jpg')
                end
                img.thumbnail(250) do |thumb|
                  thumb.save File.join(directory,'_thumb_large.jpg')
                end
              end

              self.custom_thumbnail = true
              return
            end
          rescue TypeError => error
            # ignore TypeErrors, just means it wasn't a supported image
          end
        end
        self.custom_thumbnail = false
      end

      private

     def run_later(&blk)
       Merb::Dispatcher.work_queue << blk
     end

      def remove_file_from_disk
        if File.exists?(directory)
          FileUtils.rm_r(directory) 
        end
      end

      def update_file_on_disk
        if file
          FileUtils.mkdir(directory) unless File.exists?(directory)
          FileUtils.cp file[:tempfile].path, location_on_disk

          # new file has been upload, if it is an image, then create a thumbnail
          generate_thumb
        end
      end
      
      private
      
      def generate_reference_hash
        unless attribute_get(:hash)
          attribute_set(:hash, Digest::SHA1.hexdigest(Time.now.to_s + file_name))
        end
      end
    end
  end
end