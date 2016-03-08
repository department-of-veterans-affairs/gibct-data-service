class CsvFile < ActiveRecord::Base
	belongs_to :raw_file_source, inverse_of: :csv_file
	
	validates :data, presence: true
	validates :raw_file_source_id, presence: true, uniqueness: true
end
