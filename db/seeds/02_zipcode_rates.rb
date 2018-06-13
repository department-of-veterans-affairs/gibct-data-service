module ZipcodeRateImporter
  extend self
  ZIP_MHA_PATH = File.join(Rails.root, 'db', 'seeds', 'zipcode_rate', 'zip_mha.txt')
  MHA_RATE_PATH = File.join(Rails.root, 'db', 'seeds', 'zipcode_rate', 'mha_rate.txt')
  ZIP_CITY_PATH = File.join(Rails.root, 'db', 'seeds', 'zipcode_rate', 'zip_city.csv')

  def zip_mha
    options = {
      col_sep: '|',
      headers_in_file: false,
      user_provided_headers: %w[zip_code mha_code year date],
      convert_values_to_numeric: false
    }
    SmarterCSV.process(ZIP_MHA_PATH, options)
  end

  def mha_rate
    options = {
      col_sep: '|',
      headers_in_file: false,
      user_provided_headers: %w[mha_code date mha_rate mha_rate_grandfathered],
      convert_values_to_numeric: false
    }
    SmarterCSV.process(MHA_RATE_PATH, options).group_by { |record| record[:mha_code] }
  end

  def zip_city
    options = {
      col_sep: ',',
      headers_in_file: true,
      user_provided_headers: %w[zip_code city state],
      convert_values_to_numeric: false
    }
    SmarterCSV.process(ZIP_CITY_PATH, options).group_by { |record| record[:zip_code] }
  end

  def insert_data
    records = []
    mha_rates = mha_rate
    zip_cities = zip_city
    zip_mha.each do |zip_mha_record|
      mha_rate_data = mha_rates[zip_mha_record[:mha_code]].first.slice(*%i[mha_rate mha_rate_grandfathered])
      mha_name_data = { mha_name: zip_cities[zip_mha_record[:zip_code]]&.first&.slice(*%i[city state])&.values&.join(', ') }
      records << ZipcodeRate.new(zip_mha_record.slice(*%i[zip_code mha_code])
                               .merge(mha_rate_data)
                               .merge(mha_name_data))
    end
    records
  end
end

puts 'Deleting old zipcode_rates'
ZipcodeRate.delete_all

puts 'Building Zipcode Rates'
# import in batches of 1000
ZipcodeRateImporter.insert_data.each_slice(1000) do |slice|
  ZipcodeRate.import slice, validate: false, ignore: true
end
