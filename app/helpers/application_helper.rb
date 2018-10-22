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
end