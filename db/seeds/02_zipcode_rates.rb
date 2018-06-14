module ZipcodeRateImporter
  extend self
  ZIP_MHA_PATH = File.join(Rails.root, 'db', 'seeds', 'zipcode_rate', 'zip_mha.txt')
  MHA_RATE_PATH = File.join(Rails.root, 'db', 'seeds', 'zipcode_rate', 'mha_rate.txt')
  ZIP_CITY_PATH = File.join(Rails.root, 'db', 'seeds', 'zipcode_rate', 'zip_city.csv')

  def zip_mhas_array
    return @zip_mhas if @zip_mhas
    options = {
      col_sep: '|',
      headers_in_file: false,
      user_provided_headers: %w[zip_code mha_code year date],
      convert_values_to_numeric: false
    }
    @zip_mhas = SmarterCSV.process(ZIP_MHA_PATH, options)
  end

  def mha_rates_array_grouped_by_mha_code
    return @mha_rates if @mha_rates
    options = {
      col_sep: '|',
      headers_in_file: false,
      user_provided_headers: %w[mha_code date mha_rate mha_rate_grandfathered],
      convert_values_to_numeric: false
    }
    @mha_rates = SmarterCSV.process(MHA_RATE_PATH, options).group_by { |record| record[:mha_code] }
  end

  # TODO: figure out how to do this via crosswalks instead.
  def zip_cities_array_grouped_by_zip_code
    return @zip_cities if @zip_cities
    options = {
      col_sep: ',',
      headers_in_file: true,
      user_provided_headers: %w[zip_code city state],
      convert_values_to_numeric: false
    }
    @zip_cities = SmarterCSV.process(ZIP_CITY_PATH, options).group_by { |record| record[:zip_code] }
  end

  def mha_rates_data(mha_code)
    rates = mha_rates_array_grouped_by_mha_code[mha_code]
    raise "Rate not found for mha_code #{mha_code}" if rates.nil?
    raise "Duplicate rates found for mha_code #{mha_code}" if rates.size > 1
    rates.first.slice(*%i[mha_rate mha_rate_grandfathered])
  end

  def zip_city_state_data(zip_code)
    zip_city = zip_cities_array_grouped_by_zip_code[zip_code]
    if zip_city.nil?
      puts "City State not found for zip_code #{zip_code}"
      return { mha_name: 'Unknown' }
    end
    raise "Duplicate zip city found for zip_code #{zip_code}" if zip_city.size > 1
    { mha_name: zip_city.first.slice(*%i[city state]).values.join(', ') }
  end

  def insert_data
    records = []
    zip_mhas_array.each do |zip_mha_record|
      rates_data = mha_rates_data(zip_mha_record[:mha_code])
      name_data = zip_city_state_data(zip_mha_record[:zip_code])
      records << ZipcodeRate.new(zip_mha_record.slice(*%i[zip_code mha_code])
                               .merge(rates_data)
                               .merge(name_data))
    end
    records
  end
end

puts 'Deleting old zipcode_rates'
ZipcodeRate.delete_all

puts 'Building Zipcode Rates'
# import in batches of 1000
ZipcodeRateImporter.insert_data.each_slice(5000) do |slice|
  ZipcodeRate.import slice, validate: false, ignore: true
end
