module Gluttonberg
  module Library
    class AssetCategories < Gluttonberg::Application
      # provides :xml, :yaml, :js

      def index
        @asset_categories = AssetCategory.all
        display @asset_categories
      end

      def show(id)
        @asset_category = AssetCategory.get(id)
        raise NotFound unless @asset_category
        display @asset_category
      end

      def new
        only_provides :html
        @asset_category = AssetCategory.new
        display @asset_category
      end

      def edit(id)
        only_provides :html
        @asset_category = AssetCategory.get(id)
        raise NotFound unless @asset_category
        display @asset_category
      end

      def create(asset_category)
        @asset_category = AssetCategory.new(asset_category)
        if @asset_category.save
          redirect resource(@asset_category), :message => {:notice => "AssetCategory was successfully created"}
        else
          message[:error] = "AssetCategory failed to be created"
          render :new
        end
      end

      def update(id, asset_category)
        @asset_category = AssetCategory.get(id)
        raise NotFound unless @asset_category
        if @asset_category.update_attributes(asset_category)
          redirect resource(@asset_category)
        else
          display @asset_category, :edit
        end
      end

      def destroy(id)
        @asset_category = AssetCategory.get(id)
        raise NotFound unless @asset_category
        if @asset_category.destroy
          redirect resource(:asset_categories)
        else
          raise InternalServerError
        end
      end

    end # AssetCategories
  end
end
