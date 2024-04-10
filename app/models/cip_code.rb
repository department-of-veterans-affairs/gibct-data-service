# frozen_string_literal: true

class CipCode < ImportableRecord
  CSV_CONVERTER_INFO = {
    'cipfamily' => { column: :cip_family, converter: Converters::BaseConverter },
    'cipcode' => { column: :cip_code, converter: Converters::BaseConverter },
    'action' => { column: :action, converter: Converters::BaseConverter },
    'textchange' => { column: :text_change, converter: Converters::BooleanConverter },
    'ciptitle' => { column: :cip_title, converter: Converters::BaseConverter },
    'cipdefinition' => { column: :cip_definition, converter: Converters::BaseConverter },
    'crossreferences' => { column: :cross_references, converter: Converters::BaseConverter },
    'examples' => { column: :examples, converter: Converters::BaseConverter }
  }.freeze
end
