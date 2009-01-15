module Gluttonberg
  class PageDescription
    @@_descriptions = {}
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
    
    def redirect_to(type = nil, opt = nil, &blk)
      if type
        @redirect_type    = type
        @redirect_option  = opt if opt
      elsif block_given?
        @redirect_type  = :block
        @redirect_block = type_or_blk
      end
      @options[:behaviour] = (type == :component ? :component : :redirect)
    end
    
    def redirect?
      !@redirect_type.nil?
    end
    
    def home?
      @options[:home]
    end
    
    def redirect_url(page, params)
      path = case @redirect_type
        when :block     then @redirect_block.call
        when :url       then @redirect_option
        when :page      then redirect_to_page(page, params)
        when :component then Merb::Router.url(@redirect_option)
      end
      Router.localized_url(path, params)
    end
    
    private
    
    def redirect_to_page(page, params)
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
