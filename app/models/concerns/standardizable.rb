module Standardizable
  extend ActiveSupport::Concern

  TRUTHY_VALUES = %w(yes ye y true t on).freeze

  class_methods do
    def forbidden_word?(v)
      %w(none null privacysuppressed).include?(v.try(:downcase))
    end

    def to_bool(value)
      value = value.downcase if value.is_a?(String)
      TRUTHY_VALUES.include?(value.to_s.downcase)
    end

    def column_definitions
      columns.each_with_object({}) { |col, m| m[col.name] = col.type }.except('id', 'created_at', 'updated_at')
    end

    def define_facility_code_writer
      define_method 'facility_code=' do |value|
        self['facility_code'] = value.strip.upcase.rjust(8, '0') if value.present?
      end
    end

    def define_generic_writer(obj, col, type)
      case type.to_sym
      when :boolean
        define_method "#{col}=" do |value|
          self[col] = value.blank? ? nil : obj.to_bool(value)
        end
      end
    end
  end

  included do
    column_definitions.each_pair do |col, type|
      writer = "define_#{col}_writer"
      respond_to?(writer) ? send(writer) : define_generic_writer(self, col, type)
    end
  end
end
