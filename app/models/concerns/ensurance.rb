module Ensurance
  extend ActiveSupport::Concern

  class_methods do
    @_additional_ensure_by = []
    @_ensure_order = nil
    @_ensure_by = []

    def ensure_by(*args, order: nil)
      @_additional_ensure_by = args
      if (::ActiveRecord::Base.connection rescue false)
        @_ensure_order = (order || primary_key).to_s
        @_ensure_by = [@_additional_ensure_by || primary_key].flatten.compact.uniq
      end
      # ap "Ensure By: #{self}.#{@_ensure_by}   Order: #{self}.#{@_ensure_order}"
    end

    def ensure(thing = nil)
      return nil unless thing.present?

      if thing.is_a?(self)
        return thing
      elsif thing.is_a?(GlobalID)
        return GlobalID::Locator.locate(thing)
      elsif thing.is_a?(Hash) && thing['_aj_globalid'] && (found = GlobalID::Locator.locate(thing['_aj_globalid']))
        return found
      elsif thing.is_a?(String) && (found = GlobalID::Locator.locate(thing))
        return found
      end

      @_ensure_by ||= [@_additional_ensure_by || primary_key].flatten.compact.uniq
      @_ensure_order ||= primary_key

      found = []
      things = [thing].flatten
      things.each do |a_thing|
        record = nil
        @_ensure_by.each do |ensure_field|
          value = a_thing
          if a_thing.is_a?(Hash)
            value = a_thing.fetch(ensure_field.to_sym, nil) || a_thing.fetch(ensure_field.to_s, nil)
          end
          if ensure_field.to_sym == :id
            begin
              # Always return the most recent record that matches
              query = where(ensure_field => value)
              query = query.order("#{@_ensure_order}" => 'desc')
              record = query.first
            rescue ActiveRecord::RecordNotFound
              nil
            end
          else
            record = find_by(ensure_field => value) if value.present? && !value.is_a?(Hash)
          end
          break if record.is_a?(self)
        end
        found << record
      end
      found.compact!

      thing.is_a?(Array) ? found : found.first
    end

    def ensure!(thing = nil)
      return nil unless thing.present?
      result = self.ensure(thing)
      raise ActiveRecord::RecordNotFound, "#{self} not found" unless result
      result
    end
  end
end
