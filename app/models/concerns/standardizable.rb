# frozen_string_literal: true
require 'carmen'

module Standardizable
  extend ActiveSupport::Concern
  include Carmen

  TRUTHY_VALUES = %w(yes ye y true t on 1).freeze

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

    def override_setters
      column_definitions.each_pair do |col, data_type|
        case col
        when 'facility_code' then override_facility_code_setter
        when 'institution' then override_institution_setter
        when 'state' then override_state_setter
        else override_generic_setter(col, data_type)
        end
      end
    end

    def override_facility_code_setter
      define_method 'facility_code=' do |value|
        self['facility_code'] = value.strip.upcase.rjust(8, '0') if value.present?
      end
    end

    def override_institution_setter
      define_method 'institution=' do |value|
        self['institution'] = value.blank? ? nil : value.strip.upcase
      end
    end

    def override_state_setter
      define_method('state=') do |value|
        value = Country.coded('us').subregions.coded(value.try(:strip))
        raise ArgumentError, "''#{value}' is not a US state'" if value.nil?

        self['state'] = value.code
      end
    end

    def override_generic_setter(col, data_type)
      case data_type.to_s
      when 'boolean' then override_generic_boolean_setter(col)
      when 'string' then override_generic_string_setter(col)
      end
    end

    def override_generic_boolean_setter(col)
      klass = self
      define_method "#{col}=" do |value|
        self[col] = value.nil? ? nil : klass.to_bool(value)
      end
    end

    def override_generic_string_setter(col)
      klass = self
      define_method "#{col}=" do |value|
        self[col] = klass.forbidden_word?(value) || (value.blank? ? nil : value.strip.delete("'"))
      end
    end
  end

  included do
  end
end
