module Gluttonberg
  module Library
    class AssetMimeTypes < Gluttonberg::Application
      # provides :xml, :yaml, :js

      def index
        @asset_mime_types = AssetMimeType.all
        display @asset_mime_types
      end

      def show(id)
        @asset_mime_type = AssetMimeType.get(id)
        raise NotFound unless @asset_mime_type
        display @asset_mime_type
      end

      def new
        only_provides :html
        @asset_mime_type = AssetMimeType.new
        display @asset_mime_type
      end

      def edit(id)
        only_provides :html
        @asset_mime_type = AssetMimeType.get(id)
        raise NotFound unless @asset_mime_type
        display @asset_mime_type
      end

      def create(asset_mime_type)
        @asset_mime_type = AssetMimeType.new(asset_mime_type)
        if @asset_mime_type.save
          redirect resource(@asset_mime_type), :message => {:notice => "AssetMimeType was successfully created"}
        else
          message[:error] = "AssetMimeType failed to be created"
          render :new
        end
      end

      def update(id, asset_mime_type)
        @asset_mime_type = AssetMimeType.get(id)
        raise NotFound unless @asset_mime_type
        if @asset_mime_type.update_attributes(asset_mime_type)
          redirect resource(@asset_mime_type)
        else
          display @asset_mime_type, :edit
        end
      end

      def destroy(id)
        @asset_mime_type = AssetMimeType.get(id)
        raise NotFound unless @asset_mime_type
        if @asset_mime_type.destroy
          redirect resource(:asset_mime_types)
        else
          raise InternalServerError
        end
      end

    end # AssetMimeTypes
  end
end