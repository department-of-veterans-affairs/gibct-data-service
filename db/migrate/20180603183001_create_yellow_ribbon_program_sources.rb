class CreateYellowRibbonProgramSources < ActiveRecord::Migration
  def change
    create_table :yellow_ribbon_program_sources do |t|
      t.string :facility_code, index: true  # utilized
      t.string :school_name_in_yr_database
      t.string :school_name_in_weams
      t.string :campus
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip
      t.string :public_private
      t.string :degree_level # utilized
      t.string :division_professional_school # utilized
      t.integer :number_of_students # utilized
      t.decimal :contribution_amount, precision: 12, scale: 2 # utilized
      t.boolean :updated_for_2011_2012
      t.boolean :missed_deadline
      t.boolean :ineligible
      t.date :date_agreement_received
      t.date :date_yr_signed_by_yr_official
      t.date :amendment_date
      t.boolean :flight_school
      t.date :date_confirmation_sent
      t.boolean :consolidated_agreement
      t.boolean :new_school
      t.boolean :open_ended_agreement
      t.boolean :modified
      t.boolean :withdrawn
      t.string :sco_name
      t.string :sco_telephone_number
      t.string :sco_email_address
      t.string :sfr_name
      t.string :sfr_telephone_number
      t.string :sfr_email_address
      t.string :initials_yr_processor
      t.string :year_of_yr_participation
      t.text :notes
      t.timestamps null: false
    end
  end
end
