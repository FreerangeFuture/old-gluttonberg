module Gluttonberg
  module DragTree
    module ControllerHelper
      def self.included(klass)
        klass.class_eval do
          @drag_tree_model_class = nil
 
          def klass.drag_class
            @drag_tree_model_class
          end

          def klass.drag_tree(model_class)
            @drag_tree_model_class = model_class
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
                  css_class_str = 'drag-tree'
                  if !self.class.drag_class.behaves_as_a_flat_drag_tree then
                    css_class_str = model.parent_id ? 'child-of-node-' + model.parent_id.to_s : ''
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
          def is_drag_tree(options = {:flat => false})
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
  end
end