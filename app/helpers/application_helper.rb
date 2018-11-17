module ApplicationHelper
  def navbar_item(path, name)
    tmp = []
    tmp << "<li class='nav-item #{'active' if current_page?(path)}'>"
    tmp << "  <a href='#{path}' class='nav-link'>"
    tmp << "    #{I18n.t(name)}" 
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
end