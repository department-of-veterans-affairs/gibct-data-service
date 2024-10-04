# frozen_string_literal: true

class Lce::Official < ImportableRecord
  CSV_CONVERTER_INFO = {
    'name' => { column: :name, converter: Converters::BaseConverter },
    'title' => { column: :name, converter: Converters::BaseConverter }
  }.freeze

  belongs_to :institution, :class_name => 'Lce::Institution'
end
