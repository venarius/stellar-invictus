module DeviseHelper
  def devise_error_messages!
    return "" unless devise_error_messages?

    msg_count = resource.errors.full_messages.count
    if msg_count > 1
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    else
      messages = resource.errors.full_messages.map { |msg| msg }.join
    end

    if msg_count > 1
      html = <<-HTML
        <div class="alert alert-danger">
          <ul class='mb-0'>#{messages}</ul>
        </div>
        HTML
    else
      html = <<-HTML
        <div class="alert alert-danger">
          #{messages}
        </div>
        HTML
    end

    html.html_safe
  end

  def devise_error_messages?
    !resource.errors.empty?
  end

end
