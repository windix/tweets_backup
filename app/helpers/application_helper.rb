module ApplicationHelper
  def build_menu(current_action_name)
    result = "<ul>\n"
    
    Tweet::TYPES.each do |type|
      action_name = type.to_s.pluralize
      result += "<li>"
      defination = Tweet::TYPES_DEFINATION[type]
      result += link_to raw("#{defination[1]}<span>#{defination[0]} (#{Tweet.get_count(type)})</span>"),
                       { :controller => "tweets", :action =>action_name },
                       :class => (current_action_name == action_name) ? 'selected' : nil 
      result += "</li>\n"
    end

    result += "</ul>\n"
  end
end
