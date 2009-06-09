module Gluttonberg
  module Library
    class Assets < Gluttonberg::Application
      include Gluttonberg::AdminController
      
      before :find_asset, :exclude => [:index, :category, :new, :create, :browser]

      def index
       redirect slice_url(:asset_category, :category => 'all')
      end
      
      def browser
        @assets = []
        @collections = AssetCollection.all_for_user(session.user , :order => [:name.asc])
        @categories = AssetCategory.all
        if params["no_frame"]
          partial(:browser_root)
        else
          render :layout => false
        end
      end
      
      def category
        provides :json
        conditions = {:order => get_order, :per_page => 18}
        if params[:category] == "all" then
          @paginator, @assets = paginate(Asset, conditions)
        else
          req_category = AssetCategory.first(:name => params[:category])
          raise BadRequest.new("Unknown category '#{params[:category]}'") if req_category.nil?
          @paginator, @assets = paginate(req_category.assets, conditions)
        end

        @paginate_previous_url = slice_url(:asset_category, :category => params[:category], :page => @paginator.previous, :order => params[:order] || 'name')
        @paginate_next_url = slice_url(:asset_category, :category => params[:category], :page => @paginator.next, :order => params[:order] || 'name')
        if content_type == :json          
          JSON.pretty_generate({
            :name     => params[:category].pluralize.capitalize,
            :backURL  => slice_url(:asset_browser, :no_frame => false),
            :markup   => partial("library/shared/asset_panels", :format => :html, :editing => false)
          })
        else
          render
        end
      end
      
      def show
        render
      end
      
      def new
        @asset = Asset.new
        prepare_to_edit
        render
      end
      
      def edit
        prepare_to_edit
        render
      end
      
      def delete
        display_delete_confirmation(
          :title      => "Delete “#{@asset.name}”?",
          :action     => slice_url(:asset, @asset),
          :return_url => slice_url(:asset, @asset)
        )
      end
      
      def create
        params["new_collection"][:user] = session.user
        the_collection = find_or_create_asset_collection_from_hash(params["new_collection"])
        if the_collection
          params["gluttonberg::asset"]['collection_ids'] = params["gluttonberg::asset"]['collection_ids'] || []
          unless params["gluttonberg::asset"]['collection_ids'].include?(the_collection.id.to_s)
            params["gluttonberg::asset"]['collection_ids'] << the_collection.id.to_s
          end
        end

        @asset = Asset.new(params["gluttonberg::asset"])
        if @asset.save
          redirect(slice_url(:asset, @asset))
        else
          prepare_to_edit
          render :new
        end
      end
      
      def update
        unless params["gluttonberg::asset"].has_key?('collection_ids') 
          # no collection ids were supplied so need to delete all collection associations
          @asset.clear_all_collections
        end
        params["new_collection"][:user] = session.user
        the_collection = find_or_create_asset_collection_from_hash(params["new_collection"])
        if the_collection
          unless params["gluttonberg::asset"]['collection_ids'].include?(the_collection.id.to_s)
            params["gluttonberg::asset"]['collection_ids'] << the_collection.id.to_s
          end
        end
        
        if @asset.update_attributes(params["gluttonberg::asset"])
          redirect(slice_url(:asset, @asset))
        else
          prepare_to_edit
          render :edit
        end
      end
      
      def destroy
        @asset.destroy
        redirect(slice_url(:library))
      end
      
      private
      
      def find_asset
        @asset = Asset.get(params[:id])
        raise NotFound unless @asset
      end
      
      def prepare_to_edit
        @dialects = Dialect.all
        @locales = Locale.all
        @collections = AssetCollection.all_for_user(session.user)
      end
      
      def get_order
        case params[:order]
        when 'name'
          [:name.asc]
        when 'date-updated'
          [:updated_at.desc]
        else
          [:created_at.desc]
        end
      end
    end
  end
end