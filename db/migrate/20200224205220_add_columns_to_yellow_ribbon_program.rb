class AddColumnsToYellowRibbonProgram < ActiveRecord::Migration[5.2]
  def change
    add_column :yellow_ribbon_programs, :amendment_date, :date
    add_column :yellow_ribbon_programs, :campus, :string
    add_column :yellow_ribbon_programs, :city, :string
    add_column :yellow_ribbon_programs, :consolidated_agreement, :boolean
    add_column :yellow_ribbon_programs, :date_agreement_received, :date
    add_column :yellow_ribbon_programs, :date_confirmation_sent, :date
    add_column :yellow_ribbon_programs, :date_yr_signed_by_yr_official, :date
    add_column :yellow_ribbon_programs, :facility_code, :string
    add_column :yellow_ribbon_programs, :flight_school, :boolean
    add_column :yellow_ribbon_programs, :ineligible, :boolean
    add_column :yellow_ribbon_programs, :initials_yr_processor, :string
    add_column :yellow_ribbon_programs, :missed_deadline, :boolean
    add_column :yellow_ribbon_programs, :modified, :boolean
    add_column :yellow_ribbon_programs, :new_school, :boolean
    add_column :yellow_ribbon_programs, :notes, :text
    add_column :yellow_ribbon_programs, :open_ended_agreement, :boolean
    add_column :yellow_ribbon_programs, :public_private, :string
    add_column :yellow_ribbon_programs, :school_name_in_weams, :string
    add_column :yellow_ribbon_programs, :school_name_in_yr_database, :string
    add_column :yellow_ribbon_programs, :sco_email_address, :string
    add_column :yellow_ribbon_programs, :sco_name, :string
    add_column :yellow_ribbon_programs, :sco_telephone_number, :string
    add_column :yellow_ribbon_programs, :sfr_email_address, :string
    add_column :yellow_ribbon_programs, :sfr_name, :string
    add_column :yellow_ribbon_programs, :sfr_telephone_number, :string
    add_column :yellow_ribbon_programs, :state, :string
    add_column :yellow_ribbon_programs, :street_address, :string
    add_column :yellow_ribbon_programs, :updated_for_2011_2012, :boolean
    add_column :yellow_ribbon_programs, :withdrawn, :boolean
    add_column :yellow_ribbon_programs, :year_of_yr_participation, :string
    add_column :yellow_ribbon_programs, :zip, :string
  end
end
