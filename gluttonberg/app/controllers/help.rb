module Gluttonberg
  class Help < Gluttonberg::Application
    include Gluttonberg::AdminController
    self._template_roots = [[Gluttonberg.root / "help", :_template_location]]
    layout "help"
    # Default help paths
    @@help_template_paths = Mash.new
    @@help_template_paths[:gluttonberg] = Gluttonberg.root / "help"
    
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
      Dir.glob(template_dir(opts) / "*").each do |template|
        return true if template.match(opts[:page])
      end
      false
    end
    
    def self.path_to_template(opts)
      dir = template_dir(opts)
      "#{dir}/#{opts[:page]}"
    end
    
    def self.template_dir(opts)
      match = opts[:controller].match(%r{^(\w+)/(\S+)})
      "#{@@help_template_paths[match[1]]}/#{match[2]}"
    end
  end
end
