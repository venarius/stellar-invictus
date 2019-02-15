module ApplicationHelper
  def navbar_item(path, name, count=0)
    tmp = []
    tmp << "<li class='nav-item #{'active' if current_page?(path)}'>"
    tmp << "  <a href='#{path}' class='nav-link #{'color-gold' if path == donate_path}'>"
    if count > 0
      tmp << "    #{I18n.t(name)}" + " (#{count})"
    else
      tmp << "    #{I18n.t(name)}"
    end
    tmp << "      <span class='sr-only'>(current)</span>" if current_page?(path)
    tmp << "  </a>"
    tmp << "</li>"
    tmp.join("\n").html_safe
  end
  
  def online_status(user)
    if user.online > 0
      "<i class='fa fa-circle fa-xs color-green'></i>&nbsp;&nbsp;#{I18n.t('helpers.online_now')}".html_safe
    else
      "<i class='fa fa-circle fa-xs color-sec-low'></i>&nbsp;&nbsp;#{I18n.t('helpers.online_ago', time: time_ago_in_words(user.last_action))}".html_safe
    end
  end
  
  def map_and_sort(users)
    users = users.map{|u| {u.full_name => u.id}}.reduce(:merge)
    if users
      users.sort.to_h
    else
      {}
    end
  end
  
  def get_item_attribute(loader, attribute)
    begin
      atty = loader.split(".")
      out = Item.item_variables[atty[0]]
      loader.count('.').times do |i|
        out = out[atty[i+1]]
      end
      out[attribute] rescue nil
    rescue 
      ""
    end
  end
end