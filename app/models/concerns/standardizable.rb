module Standardizable
  extend ActiveSupport::Concern

  TRUTHY_VALUES = %w(yes ye y true t on).freeze

  class_methods do
    def column_definitions
      columns.each_with_object({}) { |col, m| m[col.name] = col.type }.except('id', 'created_at', 'updated_at')
    end

    def forbidden_word?(v)
      %w(none null privacysuppressed).include?(v.try(:downcase))
    end

    def to_bool(value)
      value = value.downcase if value.is_a?(String)
      TRUTHY_VALUES.include?(value.to_s.downcase)
    end
  end

  included do
    KLASS = self

    column_definitions.each_pair do |col, type|
      case col
      when 'facility_code'
        define_method 'facility_code=' do |value|
          self['facility_code'] = value.strip.upcase.rjust(8, '0') if value.present?
        end
      when 'institution'
        define_method 'institution=' do |value|
          self['institution'] = value.blank? ? nil : value.strip.upcase
        end
      else
        if type == :boolean
          define_method "#{col}=" do |value|
            self[col] = value.blank? ? nil : KLASS.to_bool(value)
          end
        elsif type == :string
          define_method "#{col}=" do |value|
            self[col] = KLASS.forbidden_word?(value) || value.blank? ? nil : value.strip.delete("'")
          end
        end
      end
    end
  end
end
