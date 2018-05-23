class CreateYellowRibbons < ActiveRecord::Migration
  def change
    create_table :yellow_ribbons do |t|
      t.string :facility_code
      t.string :school_name_in_yr_database
      t.string :school_name_in_weams
      t.string :campus
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.string :public_private
      t.string :degree_level
      t.string :division_professional_school
      t.string :contribution_amount
      t.string :updated_for_2011_2012
      t.string :missed_deadline
      t.string :ineligible
      t.string :date_agreement_received
      t.string :dat_yr_signed_by_yr_official
      t.string :amendment_date
      t.string :flight_school 
      t.string :date_confirmation_sent
      t.string :consolidated_agreement
      t.string :new_school
      t.string :open_ended_agreement
      t.string :modified
      t.string :withdrawn
      t.string :sco_name
      t.string :sco_telephone_number
      t.string :sco_email_address
      t.string :sfr_name
      t.string :sfr_telephone_number
      t.string :sfr_email_address
      t.string :initials_yr_processor
      t.string :year_of_yr_participation

      t.integer :number_of_students

      t.text :notes

      t.timestamps null: false
      t.index :facility_code, unique: true
    end
  end
end
