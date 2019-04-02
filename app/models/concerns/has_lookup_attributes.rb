# frozen_string_literal: true

module HasLookupAttributes
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :default_base

    # Return a lookup attribute value using a combination of the `base` and `attribute`
    # returns `default` if not found (which defaults to `nil`)
    # e.g. `equipment.storage.small_black_hole.type`
    def get_attribute(base, attribute = nil, default: nil)
      path = [base, attribute].compact.map(&:to_s).join('.')
      # ap "#{self.name}.get_attribute(#{path}, default: #{default ? default : 'nil'})"
      parts = path.split('.')
      @lookup_data.dig(*parts) || default
    end

    # Return all the lookup attributes from a top-level key
    def get_attributes(base)
      self.get_attribute(base)
    end
  end

  def get_attribute(attribute = nil, default: nil)
    return nil if attribute.blank?
    self.class.get_attribute(self.send(self.class.default_base), attribute, default: default)
  end

  def get_attributes()
    self.class.get_attribute(self.send(self.class.default_base))
  end
end
