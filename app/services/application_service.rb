# frozen_string_literal: true

class ApplicationService < LightServiceObject::Base
  def self.failed(error)
    return nil if Rails.env.production?
    return nil if Rails.env.test?

    puts "#{self.name} FAILED".red
    root = Rails.root.to_s
    ap error
      .backtrace
      .select { |e| e.index(root) }
      .map { |e| e.gsub(root, "") }
  end

  def error_reason(error)
    # Give subclasses a chance to see errors first
    "#{error}"
  end
end
