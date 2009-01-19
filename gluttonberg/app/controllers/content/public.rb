module Gluttonberg
  module Content
    class Public < Gluttonberg::Application
      include Gluttonberg::PublicController
      
      provides :htmlf, :html, :js, :xml, :json
      
      def show
        Merb.logger.info("\n PAGE: #{page_template}\nLAYOUT: #{page_layout}\n")
        if content_type == :htmlf
          render(:template => page_template, :layout => false, :format => :html)
        else
          render(:template => page_template, :layout => page_layout)
        end
      end
    end
  end
end