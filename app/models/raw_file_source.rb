class RawFileSource < ActiveRecord::Base
	has_many :raw_files, inverse_of: :raw_file_source, dependent: :restrict_with_error
	has_one :csv_file, inverse_of: :raw_file_source, dependent: :destroy
	
	validates :name, presence: true, uniqueness: true
	validates :build_order, presence: true, uniqueness: true
end
