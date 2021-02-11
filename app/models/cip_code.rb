# frozen_string_literal: true

class CipCode < ImportableRecord
  CSV_CONVERTER_INFO = {
    'cipfamily' => { column: :cip_family, converter: BaseConverter },
    'cipcode' => { column: :cip_code, converter: BaseConverter },
    'action' => { column: :action, converter: BaseConverter },
    'textchange' => { column: :text_change, converter: BooleanConverter },
    'ciptitle' => { column: :cip_title, converter: BaseConverter },
    'cipdefinition' => { column: :cip_definition, converter: BaseConverter },
    'crossreferences' => { column: :cross_references, converter: BaseConverter },
    'examples' => { column: :examples, converter: BaseConverter }
  }.freeze
end
