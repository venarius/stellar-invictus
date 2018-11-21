renderer = Redcarpet::Render::HTML.new(no_images: true, filter_html: true, no_styles: true)
MARKDOWN = Redcarpet::Markdown.new(renderer, autolink: true, tables: true)