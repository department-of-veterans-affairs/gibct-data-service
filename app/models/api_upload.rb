class ApiUpload < ApplicationRecord
  belongs_to :user, inverse_of: :versions

  validates_associated :user
  validates :user_id, presence: true

  validates :api, presence: true

  validate :csv_type_check?

  def csv_type_check?
    return true if CSV_TYPES_ALL_TABLES.map(&:name).include?(csv_type) &&
        CSV_TYPES_HAS_API_TABLE_NAMES.include?(csv_type)

    if csv_type.present?
      errors.add(:csv_type, "#{csv_type} is not a valid CSV or API data source")
    else
      errors.add(:csv_type, 'cannot be blank.')
    end

    false
  end
end