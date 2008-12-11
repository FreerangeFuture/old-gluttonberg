module Gluttonberg
  module DragTree
    module ControllerHelperClassMethods
      def self.included(klass)
        klass.class_eval do
          @drag_tree_model_class = nil
          @drag_tree_route_name = nil
          @generate_route = true
 
          def klass.drag_class
            @drag_tree_model_class
          end

          def klass.set_drag_tree(model_class, options = {})
            @drag_tree_route_name = options[:route_name] if options[:route_name]
            @generate_route = options[:auto_gen_route] if options[:auto_gen_route]
            @drag_tree_model_class = model_class
          end

          def klass.add_route_for_drag_tree(router)
            if @generate_route then
              # add router for this controllers move_page action
              url_path_to_match = "/drag_tree/#{self.controller_name}/move_node.json"
              controller_path_to_use = self.controller_name
              router.match(url_path_to_match).to(:controller => controller_path_to_use, :action => "move_page").name(self.drag_tree_route_name)
            end
          end

          def klass.drag_tree_route_name
            if @drag_tree_route_name then
              @drag_tree_route_name
            else
              "#{self.controller_name}/move_node".to_sym
            end
          end

          def drag_tree_url
            url(self.class.drag_tree_route_name)
          end

          def drag_tree_slice_url
            slice_url(self.class.drag_tree_route_name)
          end

          def move_page
            only_provides :json

            raise Exception.new('dragtree model class not set') unless self.class.drag_class
            raise Exception.new('dragtree model class does not support drag tree operations') unless self.class.drag_class.respond_to?(:behaves_as_a_drag_tree)

            def source_in_destination_ancestry(source, destination)
              cur_node = destination
              if cur_node == source
                return true
              end
              while (cur_node.parent != source)
                cur_node = cur_node.parent
                return false if cur_node == nil
              end
              true
            end

            @pages = self.class.drag_class.all
            @mode = params[:mode]
            @source = self.class.drag_class.get(params[:source_page_id])
            @dest   = self.class.drag_class.get(params[:dest_page_id])

            if !self.class.drag_class.behaves_as_a_flat_drag_tree
              if source_in_destination_ancestry(@source, @dest)
                raise Merb::ControllerExceptions::BadRequest.new
              end
            end

            if (@mode == 'INSERT') and @source and @dest and !self.class.drag_class.behaves_as_a_flat_drag_tree
              # an insert is a reparenting operation. the source becomes the child of the
              # dest.
              @source.parent_id = @dest.id
              @source.move :highest
              JSON.pretty_generate({:success => true})
            else
              # if we are inserting after a node and that node has children, we are actually
              # reparenting to that node

              do_reparent = false
              if !self.class.drag_class.behaves_as_a_flat_drag_tree then
                if (@mode == 'AFTER') and (@dest.children.count > 0) then
                  do_reparent = true
                end
              end

              if do_reparent
                if (@source.parent_id != @dest.id)
                  @source.parent_id = @dest.id
                  @source.save!
                end
                @source.move :highest
                @source.save!
                JSON.pretty_generate({:success => true})
              else

                if !self.class.drag_class.behaves_as_a_flat_drag_tree
                  # if the pages don't have the same parent, need to reparent
                  # the @source
                  if @source.parent_id != @dest.parent_id
                    @source.parent_id = @dest.parent_id
                    @source.save!
                  end
                end

                if @mode == 'AFTER'
                  @source.move :below => @dest
                  @source.save!
                  JSON.pretty_generate({:success => true})
                elsif @mode == 'BEFORE'
                  @source.move :above => @dest
                  @source.save!
                  JSON.pretty_generate({:success => true})
                else
                  raise Merb::ControllerExceptions::BadRequest.new
                end
              end
            end
          end

          def drag_tree_table_class
            css_class_str = ''
            if self.class.respond_to?(:drag_class) then
              if self.class.drag_class then
                if self.class.drag_class.respond_to?(:behaves_as_a_drag_tree) then
                  css_class_str = 'drag-tree'
                  if self.class.drag_class.behaves_as_a_flat_drag_tree then
                    css_class_str = css_class_str + ' drag-flat'
                  end
                end
              end
            end
            css_class_str
          end

          def drag_tree_row_class(model)
            css_class_str = ''
            if self.class.respond_to?(:drag_class) then
              if self.class.drag_class then
                if self.class.drag_class.respond_to?(:behaves_as_a_drag_tree) then
                  css_class_str = 'node-pos-' + model.position.to_s
                  if !self.class.drag_class.behaves_as_a_flat_drag_tree then
                    if model.parent_id then
                      css_class_str = css_class_str + ' child-of-node-' + model.parent_id.to_s
                    end
                  end
                end
              end
            end
            css_class_str
          end

          def drag_tree_drag_point_class
            'drag-node'
          end

          def drag_tree_row_id(model)
            "node-#{model.id}"
          end
        end
      end
    end

    module ControllerHelper
      def self.included(klass)
        klass.class_eval do
          @@_drag_tree_class_list = []
          def klass.drag_tree(model_class, options = {})
            self.send(:include, Gluttonberg::DragTree::ControllerHelperClassMethods)
            self.set_drag_tree(model_class, options)

            @@_drag_tree_class_list << self
          end

          def klass.drag_tree_class_list
            @@_drag_tree_class_list
          end
        end
      end

      Merb::Controller.send(:include, self)
    end

    module ModelHelpersClassMethods
      def self.included(klass)
        klass.class_eval do
          @is_flat_drag_tree = false
          def klass.behaves_as_a_drag_tree
            true
          end
          def klass.make_flat_drag_tree
            @is_flat_drag_tree = true
          end
          def klass.behaves_as_a_flat_drag_tree
            @is_flat_drag_tree
          end
        end
      end
    end

    module ModelHelpers
      def self.included(klass)
        klass.class_eval do  
          def is_drag_tree(options = {})
            options[:flat] = true unless options.has_key?(:flat)
            self.send(:include, Gluttonberg::DragTree::ModelHelpersClassMethods)
            is_list options
            unless options[:flat]
              is_tree options
            else
              self.make_flat_drag_tree
            end
          end
        end
      end

      DataMapper::Model.send(:include, self)
    end

    module RouteHelpers
      def self.build_drag_tree_routes(router)
        Merb::Controller.drag_tree_class_list.each do |drag_controller_class|
          drag_controller_class.add_route_for_drag_tree(router)
        end
      end
    end
  end
end