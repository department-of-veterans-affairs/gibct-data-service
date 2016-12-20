# frozen_string_literal: true
module Standardizable
  extend ActiveSupport::Concern

  TRUTHY_VALUES = %w(yes ye y true t on 1).freeze

  STATES = {
    'AK' => 'Alaska', 'AL' => 'Alabama', 'AR' => 'Arkansas',
    'AS' => 'American Samoa', 'AZ' => 'Arizona',
    'CA' => 'California', 'CO' => 'Colorado', 'CT' => 'Connecticut',
    'DC' => 'District of Columbia', 'DE' => 'Delaware',
    'FL' => 'Florida', 'FM' => 'Federated States of Miconeisa',
    'GA' => 'Georgia', 'GU' => 'Guam',
    'HI' => 'Hawaii',
    'IA' => 'Iowa', 'ID' => 'Idaho', 'IDN' => 'Indonesia', 'IL' => 'Illinois',
    'IN' => 'Indiana',
    'KS' => 'Kansas', 'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'MA' => 'Massachusetts', 'MD' => 'Maryland', 'ME' => 'Maine', 'MH' => 'Marshall Islands',
    'MI' => 'Michigan', 'MN' => 'Minnesota', 'MO' => 'Missouri', 'MP' => 'Northern Mariana Islands',
    'MS' => 'Mississippi', 'MT' => 'Montana',
    'NC' => 'North Carolina', 'ND' => 'North Dakota',
    'NE' => 'Nebraska', 'NH' => 'New Hampshire', 'NJ' => 'New Jersey',
    'NM' => 'New Mexico', 'NV' => 'Nevada', 'NY' => 'New York',
    'OH' => 'Ohio', 'OK' => 'Oklahoma', 'OR' => 'Oregon',
    'PA' => 'Pennsylvania', 'PR' => 'Puerto Rico', 'PW' => 'Palau',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina', 'SD' => 'South Dakota',
    'TN' => 'Tennessee', 'TX' => 'Texas',
    'UT' => 'Utah',
    'VA' => 'Virginia', 'VI' => 'Virgin Islands', 'VT' => 'Vermont',
    'WA' => 'Washington', 'WI' => 'Wisconsin',
    'WV' => 'West Virginia',
    'WY' => 'Wyoming'
  }.freeze

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
        value = value.try(:strip)
        self['facility_code'] = value ? value.upcase.rjust(8, '0') : nil
      end
    end

    def override_institution_setter
      define_method 'institution=' do |value|
        value = value.try(:strip)
        self['institution'] = value ? value.upcase : nil
      end
    end

    def override_state_setter
      define_method('state=') do |value|
        value = value.to_s.try(:strip)
        self['state'] = STATES.keys.any? { |s| s.casecmp(value).zero? } ? value.upcase : nil
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
        value = value.to_s.try(:strip)
        self[col] = value.nil? ? nil : klass.to_bool(value)
      end
    end

    def override_generic_string_setter(col)
      klass = self

      define_method "#{col}=" do |value|
        value = value.to_s.try(:strip).try(:delete, "'")
        self[col] = klass.forbidden_word?(value) || value.blank? ? nil : value
      end
    end
  end

  included do
  end
end
