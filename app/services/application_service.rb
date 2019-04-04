# frozen_string_literal: true

class ApplicationService < LightServiceObject::Base
  def self.failed(error)
    return nil if Rails.env.production?
    # Comment out this line during testing to see the errors w/ a backtrace
    return nil if Rails.env.test?

    root = Rails.root.to_s
    ap "#{self.name} FAILED"
    ap error
      .backtrace
      .select { |e| e.index(root) }
      .map { |e| e.gsub(root, "") }
  end
end
