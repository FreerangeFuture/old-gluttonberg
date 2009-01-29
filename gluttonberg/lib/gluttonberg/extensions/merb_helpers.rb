module Merb::Helpers::Form::Builder
  class Base
    def update_bound_select(method, attrs)
      attrs[:value_method] ||= method
      attrs[:text_method] ||= attrs[:value_method] || :to_s
      attrs[:selected] ||= control_value(method)
    end
    
    def bound_radio_button(method, attrs = {})
      name = control_name(method)
      update_bound_controls(method, attrs, "radio")
      unbound_radio_button({:name => name}.merge(attrs))
    end

    def update_bound_controls(method, attrs, type)
      case type
      when "checkbox"
        update_bound_check_box(method, attrs)
      when "select"
        update_bound_select(method, attrs)
      when "radio"
        update_bound_radio_button(method, attrs)
      end
    end

    def update_bound_radio_button(method, attrs)
      if attrs[:value]
        attrs[:checked] = "checked" if attrs[:value] == control_value(method)
      else
        attrs[:value] = control_value(method)
      end
    end
  end
end
