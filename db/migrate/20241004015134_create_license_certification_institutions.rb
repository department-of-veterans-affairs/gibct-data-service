class CreateLicenseCertificationInstitutions < ActiveRecord::Migration[7.1]
  def change
    create_table :license_certification_institutions do |t|
      t.string :name
      t.string :abbreviated_name
      t.string :physical_street
      t.string :physical_city
      t.string :physical_zip
      t.string :physical_country
      t.string :mailing_street
      t.string :mailing_city
      t.string :mailing_zip
      t.string :mailing_country
      t.string :phone
      t.string :web_address

      t.timestamps
    end
  end
end
