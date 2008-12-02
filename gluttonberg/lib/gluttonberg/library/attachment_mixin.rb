require 'image_science'

module Gluttonberg
  module Library
    module AttachmentMixin
      def self.included(klass)
        klass.class_eval do
          property :name,         String
          property :description,  DataMapper::Types::Text
          property :file_name,    String, :length => 255
          property :hash,         String, :length => 255, :writer => :private
          property :size,         Integer
          
          after   :destroy, :remove_file_from_disk
          before  :save,    :generate_reference_hash
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
        "/assets/#{hash}/_thumb_small.jpg"
      end

      def thumb_large_url
        "/assets/#{hash}/_thumb_large.jpg"
      end
      
      def location_on_disk
        directory / file_name
      end
      
      def directory
        Library.root / hash
      end

      def generate_thumb
        ImageScience.with_image(location_on_disk) do |img|
#          img.thumbnail(64) do |thumb|
#            thumb.save File.join(directory,'_thumb.jpg')
#          end

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

        end
      end

      private

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