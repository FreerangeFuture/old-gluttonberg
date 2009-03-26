module Gluttonberg
  module Library
    module AttachmentMixin
      DEFAULT_THUMBNAILS = {
        :small_thumb => {:label => "Small Thumb", :filename => "_thumb_small", :width => 110, :height => 75},
        :large_thumb => {:label => "Large Thumb", :filename => "_thumb_large", :width => 250, :height => 200}
      }

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
      end
      
      module InstanceMethods
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

        def thumb_small_url
          url_for(:small_thumb)
        end

        def thumb_large_url
          url_for(:large_thumb)
        end

        def location_on_disk
          directory / file_name
        end

        def directory
          Library.root / asset_hash
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
            FileUtils.chmod(0755, location_on_disk)
            # new file has been upload, if it is an image, then create a thumbnail
            generate_thumb
          end
        end

        def generate_reference_hash
          unless attribute_get(:asset_hash)
            attribute_set(:asset_hash, Digest::SHA1.hexdigest(Time.now.to_s + file_name))
          end
        end
      end # InstanceMethods
    end # AttachmentMixin
  end # Library
end # Gluttonberg