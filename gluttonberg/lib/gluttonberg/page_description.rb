module Gluttonberg
  class PageDescription
    @@_descriptions = {}
    @@_categorised_descriptions = {}
    @@_description_names = {}
    @@_home_page    = nil
    
    attr_accessor :options
    
    def initialize(name)
      @options = {
        :name       => name,
        :home       => false,
        :behaviour  => :default,
        :layout     => "default",
        :view       => "default"
      }
      @sections = {}
      @@_descriptions[name] = self
    end
    
    %w(label view layout limit description).each do |opt|
      class_eval %{
        def #{opt}(opt_value)
          @options[:#{opt}] = opt_value
        end
      }
    end
    
    # This is a destructive method which removes all page definitions. Mainly
    # used for testing and debugging.
    def self.clear!
      @@_descriptions.clear
      @@_categorised_descriptions.clear
      @@_description_names.clear
      @@_home_page = nil
    end
    
    # This just loads the page_descriptions.rb file from the config dir.
    #
    # The specified file should contain the various page descriptions.
    def self.setup
      path = Merb.dir_for(:config) / "page_descriptions.rb"
      require path if File.exists?(path)
    end
    
    def self.add(&blk)
      class_eval(&blk)
    end
    
    def self.page(name, &blk)
      new(name).instance_eval(&blk)
    end
    
    def self.[](name)
      @@_descriptions[name]
    end
    
    # Returns the full list of page descriptions as a hash.
    def self.all
      @@_descriptions
    end
    
    # Returns all the descriptions with the matching behaviour in an array.
    def self.behaviour(name)
      @@_categorised_descriptions[name] ||= @@_descriptions.inject([]) do |memo, desc|
        memo << desc[1] if desc[1][:behaviour] == name
        memo
      end
    end
    
    # Collects all the names of the descriptions which have the specified 
    # behaviour.
    def self.names_for(name)
      @@_description_names[name] ||= self.behaviour(name).collect {|d| d[:name]}
    end
    
    def [](opt)
      @options[opt]
    end
    
    def sections
      @sections
    end
    
    def home(bool)
      @options[:home] = bool
      if bool
        @@_home_page = self
        @options[:limit] = 1
      elsif @@_home_page == self
        @@_home_page = nil
        @options.delete(:limit)
      end
    end
    
    def section(name, &blk)
      new_section = Section.new(name)
      new_section.instance_eval(&blk)
      @sections[name] = new_section
    end
    
    # Configures the page to act as a rewrite to named route. This doesn’t 
    # work like a rewrite in the traditional sense, since it is intended to be
    # used to redirect requests to a controller. Becuase of this it can't rewrite
    # to a path, it needs to use a named route.
    def rewrite_to(route)
      @rewrite_route = route
      @options[:behaviour] = :rewrite
    end
    
    # Returns the named route to be used when rewriting the request.
    def rewrite_route
      @rewrite_route
    end
    
    def redirect_to(type = nil, opt = nil, &blk)
      @redirect_option      = opt if opt
      @redirect_block       = blk if block_given?
      @redirect_type        = type
      @options[:behaviour]  = :redirect
    end
    
    def redirect?
      !@redirect_type.nil?
    end
    
    def home?
      @options[:home]
    end
    
    def redirect_url(page, params)
      case @redirect_type
        when :remote
          redirect_value(page, params)
        when :path
          Router.localized_url(redirect_value(page, params), params)
        when :page
          path_to_page(page, params)
      end
    end
    
    private
    
    def redirect_value(page, params)
      @redirect_block ? @redirect_block.call(page, params) : @redirect_option
    end
    
    def path_to_page(page, params)
      localization = PageLocalization.first(
        :fields   => [:path],
        :page_id  => page.redirect_target_id,
        :locale   => params[:locale],
        :dialect  => params[:dialect]
      )
      raise DataMapper::ObjectNotFoundError unless localization
      localization.path
    end
    
    class Section
      def initialize(name)
        @options = {:name => name, :limit => 1}
        @custom_config = {}
      end
      
      %w(type limit label).each do |opt|
        class_eval %{
          def #{opt}(opt_value)
            @options[:#{opt}] = opt_value
          end
        }
      end
      
      def configure(opts)
        @custom_config ||= {}
        @custom_config.merge!(opts)
      end
      
      def [](opt)
        @options[opt]
      end
      
      def config
        @custom_config
      end
    end # Section
  end # PageDescription
end # Gluttonberg
