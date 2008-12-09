module Gluttonberg
  module DragTree
    module ControllerHelper
      def self.included(klass)
        klass.class_eval do
          @@drag_tree_model_class = false

          def self.drag_tree(model_class)
            @@drag_tree_model_class = model_class
          end

          def move_page
            only_provides :json

            raise Exception.new('dragtree model class not set') unless @@drag_tree_model_class

            def source_in_destination_ancestry(source, destination)
              cur_node = destination
              if cur_node == source
                return true
              end
              while (cur_node.parent != source)
                p '----------------'
                p cur_node
                cur_node = cur_node.parent
                return false if cur_node == nil
              end
              true
            end

            # "mode"=>"INSERT", "action"=>"move_page", "dest_page_id"=>"3", "source_page_id"=>"4"
            p 'class'
            p @@drag_tree_model_class
            @pages = @@drag_tree_model_class.all
            @mode = params[:mode]
            @source = @@drag_tree_model_class.get(params[:source_page_id])
            @dest   = @@drag_tree_model_class.get(params[:dest_page_id])

            if source_in_destination_ancestry(@source, @dest)
              raise Merb::ControllerExceptions::BadRequest.new
            end

            if (@mode == 'INSERT') and @source and @dest
              # an insert is a reparenting operation. the source becomes the child of the
              # dest.
              @source.parent_id = @dest.id
              @source.move :highest
              JSON.pretty_generate({:success => true})
            else
              # if we are inserting after a node and that node has children, we are actually
              # reparenting to that node
              if (@mode == 'AFTER') and (@dest.children.count > 0)
                if (@source.parent_id != @dest.id)
                  @source.parent_id = @dest.id
                  @source.save!
                end
                @source.move :highest
                @source.save!
                JSON.pretty_generate({:success => true})
              else

                # if the pages don't have the same parent, need to reparent
                # the @source
                if @source.parent_id != @dest.parent_id
                  @source.parent_id = @dest.parent_id
                  @source.save!
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

          def drag_tree_table_class_for(model_class)
            # check if model_class supports dragTree and if it needs to be flat
            'drag-tree'
          end
        end
      end

      Merb::Controller.send(:include, self)
    end
  end
end