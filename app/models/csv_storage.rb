class CsvStorage < ActiveRecord::Base
	validates :csv_file_type, uniqueness: true, inclusion: { in: CsvFile::STI.keys  }
end
