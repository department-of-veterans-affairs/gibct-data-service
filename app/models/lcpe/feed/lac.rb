class Lcpe::Feed::Lac < ImportableRecord
  CSV_CONVERTER_INFO = {
    'facility_code' => { column: :facility_code, converter: Converters::BaseConverter },
    'edu_lac_type_nm' => { column: :edu_lac_type_nm, converter: Converters::BaseConverter },
    'lac_nm' => { column: :lac_nm, converter: Converters::BaseConverter },
    'test_nm' => { column: :test_nm, converter: Converters::BaseConverter },
    'fee_amt' => { column: :fee_amt, converter: Converters::BaseConverter }
  }.freeze

  def self.execute_rebuild
    result = [
      "BEGIN;",
      Lcpe::Lac.rebuild,
      Lcpe::LacTest.rebuild,
      "COMMIT;"
    ].flatten(1).join("\n")
    execute(result)
  end
end
