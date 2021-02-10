# frozen_string_literal: true

class CipCode < ImportableRecord
  CSV_CONVERTER_INFO = {
    'cip_family' => { column: :cip_family, converter: BaseConverter },
    'cip_code' => { column: :cip_code, converter: BaseConverter },
    'action' => { column: :action, converter: BaseConverter },
    'text_change' => { column: :text_change, converter: BooleanConverter },
    'cip_title' => { column: :cip_title, converter: BaseConverter },
    'cip_definition' => { column: :cip_definition, converter: BaseConverter },
    'cross_references' => { column: :cross_references, converter: BaseConverter },
    'examples' => { column: :examples, converter: BaseConverter }
  }.freeze
end
