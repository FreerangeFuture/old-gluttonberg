module Gluttonberg
  module Library
    class AssetTypes < Gluttonberg::Application
      # provides :xml, :yaml, :js

      def index
        @asset_types = AssetType.all
        display @asset_types
      end

      def show(id)
        @asset_type = AssetType.get(id)
        raise NotFound unless @asset_type
        display @asset_type
      end

      def new
        only_provides :html
        @asset_type = AssetType.new
        display @asset_type
      end

      def edit(id)
        only_provides :html
        @asset_type = AssetType.get(id)
        raise NotFound unless @asset_type
        display @asset_type
      end

      def create(asset_type)
        @asset_type = AssetType.new(asset_type)
        if @asset_type.save
          redirect resource(@asset_type), :message => {:notice => "AssetType was successfully created"}
        else
          message[:error] = "AssetType failed to be created"
          render :new
        end
      end

      def update(id, asset_type)
        @asset_type = AssetType.get(id)
        raise NotFound unless @asset_type
        if @asset_type.update_attributes(asset_type)
          redirect resource(@asset_type)
        else
          display @asset_type, :edit
        end
      end

      def destroy(id)
        @asset_type = AssetType.get(id)
        raise NotFound unless @asset_type
        if @asset_type.destroy
          redirect resource(:asset_types)
        else
          raise InternalServerError
        end
      end

    end # AssetTypes
  end
end