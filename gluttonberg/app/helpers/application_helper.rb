module Merb
  module Gluttonberg
    module ApplicationHelper;
      # Returns a link for sorting assets in the library
      def sorter_link(name, param, route_opts = {})
        opts = {}
        if param == params[:order] || (!params[:order] && param == 'date-added')
          opts[:class] = "current"
        end
        
        route_opts = route_opts.merge(:order => param, :page => params[:page] || 1)
        link_to(name, slice_url(route_opts.delete(:route), route_opts), opts)
      end
      
      # Writes out a row for each page and then for each page's children, 
      # iterating down through the heirarchy.
      def page_table_rows(pages, output = "", inset = 0)
        pages.each do |page|
          output << partial("content/pages/row", :page => page, :inset => inset)
          page_table_rows(page.children, output, inset + 1)
        end
        output
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def image_path(*segments)
        public_path_for(:image, *segments)
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def javascript_path(*segments)
        public_path_for(:javascript, *segments)
      end
      
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def stylesheet_path(*segments)
        public_path_for(:stylesheet, *segments)
      end
      
      # Construct a path relative to the public directory
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path relative to the public directory, with added segments.
      def public_path_for(type, *segments)
        ::Gluttonberg.public_path_for(type, *segments)
      end
      
      # Construct an app-level path.
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path within the host application, with added segments.
      def app_path_for(type, *segments)
        ::Gluttonberg.app_path_for(type, *segments)
      end
      
      # Construct a slice-level path.
      # 
      # @param <Symbol> The type of component.
      # @param *segments<Array[#to_s]> Path segments to append.
      #
      # @return <String> 
      #  A path within the slice source (Gem), with added segments.
      def slice_path_for(type, *segments)
        ::Gluttonberg.slice_path_for(type, *segments)
      end
      
      
    end
  end
end