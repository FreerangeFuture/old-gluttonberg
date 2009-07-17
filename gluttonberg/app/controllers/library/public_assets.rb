module Gluttonberg
  module Library
    class PublicAssets < Gluttonberg::Application
      
      def show                
        @asset = Asset.first(:id=>params[:id] , :asset_hash.like => params[:hash] + "%")
        raise Merb::ControllerExceptions::NotFound if @asset.blank?        
        redirect "http://#{request.host}#{@asset.url}"
      end  
      
    end  
  end
end