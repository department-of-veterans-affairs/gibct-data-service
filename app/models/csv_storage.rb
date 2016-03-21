class CsvStorage < ActiveRecord::Base
	FIELD_LIST = [:facility_code, :institution_name, ]
	validates :csv_file_type, uniqueness: true, inclusion: { in: CsvFile::STI.keys  }
end
