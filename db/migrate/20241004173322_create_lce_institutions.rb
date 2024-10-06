class CreateLceInstitutions < ActiveRecord::Migration[7.1]
  def change
    create_table :lce_institutions do |t|
      t.integer :ptcpnt_id
      t.string :name
      t.string :abbreviated_name
      t.string :physical_street
      t.string :physical_city
      t.string :physical_state
      t.string :physical_zip
      t.string :physical_country
      t.string :mailing_street
      t.string :mailing_city
      t.string :mailing_state
      t.string :mailing_zip
      t.string :mailing_country
      t.string :phone
      t.string :web_address

      t.timestamps
    end
  end
end
