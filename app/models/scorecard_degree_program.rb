# frozen_string_literal: true

class ScorecardDegreeProgram < ImportableRecord
  CSV_CONVERTER_INFO = {

    'unitid' => { column: :unitid, converter: Converters::NumberConverter },
    'ope6_id' => { column: :ope6_id, converter: Converters::BaseConverter },
    'control' => { column: :control, converter: Converters::NumberConverter },
    'main' => { column: :main, converter: Converters::NumberConverter },
    'cip_code' => { column: :cip_code, converter: Converters::BaseConverter },
    'cip_desc' => { column: :cip_desc, converter: Converters::BaseConverter },
    'cred_lev' => { column: :cred_lev, converter: Converters::NumberConverter },
    'cred_desc' => { column: :cred_desc, converter: Converters::BaseConverter }
  }.freeze

  API_SOURCE = 'https://collegescorecard.ed.gov/data/'

  def self.populate
    results = ScorecardDegreeProgramApi::Service.populate
    load(results) if results.any?
    results.any?
  end
end
