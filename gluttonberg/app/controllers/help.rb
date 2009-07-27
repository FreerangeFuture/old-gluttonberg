module Gluttonberg
  class Help < Gluttonberg::Application
    include Gluttonberg::AdminController
    
    # Default help paths
    @@gluttonberg_help_path = Gluttonberg.root / "help"
    @@app_help_path = Merb.root / "help" unless Gluttonberg.standalone?
    
    self._template_roots = [[@@gluttonberg_help_path, :_template_location]]
    
    layout "help"
    
    def show
      template = self.class.path_to_template(:controller => params[:module_and_controller], :page => params[:page])
      opts = {:template => template}
      opts[:layout] = "ajax" if request.xhr?
      render(opts)
    end
    
    def self.register(mod, path)
      @@help_template_paths[mod] = path
    end
    
    def self.help_available?(opts)
      dir = template_dir(opts)
      if dir
        Dir.glob(dir / "*").each do |template|
          return true if template.match(opts[:page].to_s)
        end
      end
      false
    end
    
    def self.path_to_template(opts)
      dir = template_dir(opts)
      "#{dir}/#{opts[:page]}"
    end
    
    def self.template_dir(opts)
      if opts[:controller].index("gluttonberg")
        match = opts[:controller].match(%r{^gluttonberg/(\S+)})
        "#{@@gluttonberg_help_path}/#{match[1]}" if match
      else
        # Strip the admin module
        "#{@@app_help_path}/#{opts[:controller].gsub("admin/", "")}"
      end
    end
  end
end
