module Gluttonberg
  module Library
    # The attachment mixin encapsulates the majority of logic for handling and 
    # processing uploads. It exists here in a mixin rather than in the Asset
    # class purely because it is ultimately the intention to have a different 
    # Asset class for each major category of assets e.g. ImageAsset, 
    # DocumentAsset.
    module AttachmentMixin
      # Default sizes used when thumbnailing an image.
      DEFAULT_THUMBNAILS = {
        :small_thumb => {:label => "Small Thumb", :filename => "_thumb_small", :width => 110, :height => 75},
        :large_thumb => {:label => "Large Thumb", :filename => "_thumb_large", :width => 250, :height => 200} 
      }
      
      # The default max image size. This can be overwritten on a per project 
      # basis via the slice configuration.
      MAX_IMAGE_SIZE = {:width => 2000, :height => 2000}
      
      # The included hook adds the ivars and properties we need. It also checks 
      # to see if image science is available, in which case it will turn image
      # thumbnailing on.
      def self.included(klass)
        klass.class_eval do
          property :name,             String
          property :description,      DataMapper::Types::Text, :lazy => false
          property :file_name,        String, :length => 255
          property :asset_hash,       String, :length => 255, :writer => :private, :field => 'hash'
          property :size,             Integer
          # if custom_thumbnail is false thumbs for the category will
          # be used. If true thumbs form the assets file location will
          # be used.
          property :custom_thumbnail, DataMapper::Types::Boolean, :default => false

          after   :destroy, :remove_file_from_disk
          before  :save,    :generate_reference_hash
          
          class << self
            attr_reader :thumbnail_sizes, :generate_thumbs
          end

          extend ClassMethods
          include InstanceMethods
          
          @generate_thumbs = begin
            require 'image_science'
          rescue LoadError
            false
          end
        end
      end
      
      module ClassMethods
        # Generates/Re-generates thumbnails for all the image assets in the 
        # library.
        def generate_all_thumbnails
          assets = Gluttonberg::Asset.all
          assets.each do |asset|
            p "thumb-nailing '#{asset.file_name}'"
            asset.generate_image_thumb
            asset.save
          end
          'done' # this just makes the output nicer when running from slice -i
        end
        
        # Returns a collection of thumbnail definitions — sizes, filename etc. — 
        # which is a merge of defaults and any custom thumbnails defined by the 
        # user.
        def sizes
          @thumbnail_sizes ||= if Gluttonberg.config[:thumbnails]
            Gluttonberg.config[:thumbnails].merge(DEFAULT_THUMBNAILS)
          else
            DEFAULT_THUMBNAILS
          end
        end
        
        # Returns the max image size as a hash containing :width and :height.
        # May be the default, or the value configured for a particular project.
        def max_image_size
          Gluttonberg.config[:max_image_size] || MAX_IMAGE_SIZE
        end
      end
      
      module InstanceMethods
        # Setter for the file object. It sanatises the file name and stores in 
        # the filename property. It also sets the mime-type and size.
        def file=(new_file)
          unless new_file.blank?
            Merb.logger.info("\nFILENAME: #{new_file[:filename]} \n\n")
            
            # Forgive me this naive sanitisation, I'm still a regex n00b
            clean_filename = new_file[:filename].split(%r{[\\|/]}).last
            clean_filename = clean_filename.gsub(" ", "_").gsub(/[^A-Za-z0-9\-_.]/, "").downcase

            # _thumb.jpg is a reserved name for the thumbnailing system, so if the user
            # has a file with that name rename it.
            if (clean_filename == '_thumb_small.jpg') || (clean_filename == '_thumb_large.jpg')
              clean_filename = 'thumb.jpg'
            end
            
            attribute_set(:mime_type, new_file[:content_type])
            attribute_set(:file_name, clean_filename)
            attribute_set(:size, new_file[:size])
            @file = new_file
          end
        end

        # Returns the file assigned by file=
        def file
          @file
        end

        # Returns the public URL to this asset, relative to the domain.
        def url
          "/assets/#{asset_hash}/#{file_name}"
        end
        
        # Returns the URL for the specified image size.
        def url_for(name)
          if custom_thumbnail
            filename = self.class.sizes[name][:filename]
            "/assets/#{asset_hash}/#{filename}.jpg"
          else
            if Gluttonberg.standalone?
              "/images/category/#{category}/_thumb_small.jpg"
            else
              "/slices/gluttonberg/images/category/#{category}/_thumb_small.jpg"
            end
          end
        end

        # Returns the public URL to the asset’s small thumbnail — relative 
        # to the domain.
        def thumb_small_url
          url_for(:small_thumb)
        end

        # Returns the public URL to the asset’s large thumbnail — relative 
        # to the domain.
        def thumb_large_url
          url_for(:large_thumb)
        end

        # Returns the full path to the file’s location on disk.
        def location_on_disk
          directory / file_name
        end
        
        # In the case where an uploaded image has been larger that the 
        # specified max-size and consequently resized, this method will provide
        # the path to the original, un-altered file.
        def original_file_on_disk
          directory / "original_" + file_name
        end

        # The generated directory where this file is located. If it is an image
        # it’s thumbnails will be stored here as well.
        def directory
          Library.root / asset_hash
        end

        # Generates thumbnails for images, but also additionally checks to see 
        # if the uploaded image exceeds the specified maximum, in which case it 
        # will resize it down.
        def generate_thumb_and_proper_resolution
          # first assign the default thumbs for the category
          # then spawn a worker to generate thumbs if possible and update
          asset_id_to_process = self.id
          run_later do
            asset = Asset.get(asset_id_to_process)
            if asset
              asset.generate_proper_resolution
              asset.generate_image_thumb
              asset.save!
            end
          end
        end
        
        # Create thumbailed versions of image attachements.
        # TODO: generate thumbnails with the correct extension
        def generate_image_thumb
          if self.class.generate_thumbs
            begin
              ImageScience.with_image(location_on_disk) do |img|
                self.class.sizes.each_pair do |name, config|
                  path = File.join(directory, "#{config[:filename]}.jpg")
                  if img.height >= img.width
                    if img.height > config[:height]
                      img.thumbnail(config[:height]) { |thumb| thumb.save(path) }
                    else
                      img.save(path)
                    end
                  else
                    if img.width > config[:width]
                      img.thumbnail(config[:width]) { |thumb| thumb.save(path) }
                    else
                      img.save(path)
                    end
                  end               
                end
                attribute_set(:custom_thumbnail, true)
              end
            rescue TypeError => error
              # ignore TypeErrors, just means it wasn't a supported image
            end
          else
            attribute_set(:custom_thumbnail, false)
          end
        end

        def generate_proper_resolution
          if self.class.generate_thumbs
            begin
              ImageScience.with_image(location_on_disk) do |img|
                  config = self.class.max_image_size
                  path = File.join(directory, file_name)
                  if img.height >= img.width
                    if img.height > config[:height]
                      make_backup
                      img.thumbnail(config[:height]) { |thumb| thumb.save(path) }
                    end
                  else
                    if img.width > config[:width]
                      make_backup
                      img.thumbnail(config[:width]) { |thumb| thumb.save(path) }
                    end
                  end                 
              end
            rescue TypeError => error
              # ignore TypeErrors, just means it wasn't a supported image
            end
          else
            attribute_set(:custom_thumbnail, false)
          end
        end
        
        private

        def make_backup
          FileUtils.cp location_on_disk, original_file_on_disk
          FileUtils.chmod(0755,original_file_on_disk)
        end
        
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
            FileUtils.chmod(0755, location_on_disk)

            # new file has been upload, if it is an image, then create a thumbnail
            generate_thumb_and_proper_resolution
          end
        end

        def generate_reference_hash
          unless attribute_get(:asset_hash)
            attribute_set(:asset_hash, Digest::SHA1.hexdigest(Time.now.to_s + file_name))
          end
        end
      end
    end # AttachmentMixin
  end # Library
end # Gluttonberg
