require 'merb-parts'

module Gluttonberg
  module RedClothPartials
    module PartsControllerMixin
      @@partials_class_list = []

      def self.included(klass)
        klass.class_eval do

          # register this PartsContollers actions with a specific route. This is aroute
          # used in the RedCloth extension to embed partials data into a
          # page section using RedCloth
          #
          #   class Films < PartController
          #     partials :summary, {:recent => :latest}
          #     partial_route :movies
          #
          #     def summary(id)
          #       "<div class='film'>#{id}</div>"
          #     end
          #
          #     def recent
          #       id = Film.most_recent
          #       summary(id)
          #     end
          #
          #   end
          #
          #   callable in texile like so:
          #
          #   irb> RedCloth.new('blah blah {{movies/summary/4}} blah blah').to_html
          #   > "<p>blah blah <div class='film'>4</div> blah blah</p>"
          #
          #   irb> RedCloth.new('blah blah {{movies/latest}} blah blah').to_html
          #   > "<p>blah blah <div class='film'>78</div> blah blah</p>"
          #
          def self.partials(*actions)
            actions.each do |action|


              routedef = RouteDefination.new(self, action, route)
              @@partials_class_list << routedef
            end
          end

          def self.partial_route(route)
            
          end
        end
      end

    end

    class RouteDefination
      attr_accessor :controller_route_name
      attr_accessor :controller
      attr_accessor :actions

      def initialization(*action_definations)
        @actions = []

        *action_definations.each do |action_def|
          if action_def.is_a?(Hash) then
            
          else
            action_def = action_def.to_sym


          end
        end
      end
    end

    class Renderer
      def self.render(controller, content)
        content.scan(/(\{\{(\w+\/\w+[\w|\/]*)\}\})/) do |match|
          if match.length == 2 then
            partial_url = match[1]
            p partial_url
            return controller.part(Bar => :baz)
          end
        end

        content
      end
    end
  end
end