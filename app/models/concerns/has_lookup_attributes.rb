# frozen_string_literal: true

module HasLookupAttributes
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :default_base

    def get_attribute(base, attribute, default: nil)
      path = [base,attribute].compact.map(&:to_s).join('.')
      # ap "get_attribute(#{path}, default: #{default ? default : 'nil'})"
      parts = path.split('.')
      @lookup_data.dig(*parts) || default
    end
  end

  def get_attribute(attribute = nil, default: nil)
    return nil if attribute.blank?
    self.class.get_attribute(self.send(self.class.default_base), attribute, default: default)
  end
end