# frozen_string_literal: true

class ScorecardDegreeProgram < ImportableRecord
  CSV_CONVERTER_INFO = {

    'unitid' => { column: :unitid, converter: NumberConverter },
    'ope6_id' => { column: :ope6_id, converter: BaseConverter },
    'control' => { column: :control, converter: NumberConverter },
    'main' => { column: :main, converter: NumberConverter },
    'cip_code' => { column: :cip_code, converter: BaseConverter },
    'cip_desc' => { column: :cip_desc, converter: BaseConverter },
    'cred_lev' => { column: :cred_lev, converter: NumberConverter },
    'cred_desc' => { column: :cred_desc, converter: BaseConverter }
  }.freeze

  API_SOURCE = 'https://collegescorecard.ed.gov/data/'

  def self.populate
    results = ScorecardDegreeProgramApi::Service.populate
    load(results) if results.any?
    results.any?
  end
end
