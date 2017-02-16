class Upload < ActiveRecord::Base
  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :filename, presence: true
  validates :csv_type, inclusion: { in: InstitutionBuilder::TABLES.map(&:name) }
end
