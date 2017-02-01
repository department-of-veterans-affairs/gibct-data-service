###############################################################################
## CsvStorage
## Holds the raw CSV image, and is the first step in the ingestion of a CSV
## file. Allows the stakeholders to download the last uploaded CSV.
###############################################################################
class CsvStorage < ActiveRecord::Base
  validates :csv_file_type, uniqueness: true, inclusion: { in: CsvFile::STI.keys }
end
