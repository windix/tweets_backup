module ApplicationHelper
  def build_menu(current_controller_name)
    result = "<ul>\n"
    
    Tweet::TYPES.each do |type|
      controller_name = type.to_s.pluralize
      result += "<li>"
      defination = Tweet::TYPES_DEFINATION[type]
      result += link_to raw("#{defination[1]}<span>#{defination[0]}</span>"),
                       { :controller => controller_name, :action => "index" },
                       :class => (current_controller_name == controller_name) ? 'selected' : nil 
      result += "</li>\n"
    end

    result += "</ul>\n"
  end
end
