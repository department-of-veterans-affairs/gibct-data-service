class RemoveUnusedColumnsFromYellowRibbon < ActiveRecord::Migration[7.1]
  def change
    # Remove columns from yellow_ribbon_program_sources
    safety_assured {
      remove_column :yellow_ribbon_program_sources, :street_address, :string
      remove_column :yellow_ribbon_program_sources, :zip, :string
      remove_column :yellow_ribbon_program_sources, :amendment_date, :date
      remove_column :yellow_ribbon_program_sources, :consolidated_agreement, :boolean
      remove_column :yellow_ribbon_program_sources, :date_yr_signed_by_yr_official, :date
      remove_column :yellow_ribbon_program_sources, :date_confirmation_sent, :date
      remove_column :yellow_ribbon_program_sources, :flight_school, :boolean
      remove_column :yellow_ribbon_program_sources, :ineligible, :boolean
      remove_column :yellow_ribbon_program_sources, :initials_yr_processor, :string
      remove_column :yellow_ribbon_program_sources, :missed_deadline, :boolean
      remove_column :yellow_ribbon_program_sources, :modified, :boolean
      remove_column :yellow_ribbon_program_sources, :new_school, :boolean
      remove_column :yellow_ribbon_program_sources, :notes, :text
      remove_column :yellow_ribbon_program_sources, :open_ended_agreement, :boolean
      remove_column :yellow_ribbon_program_sources, :public_private, :string
      remove_column :yellow_ribbon_program_sources, :school_name_in_weams, :string
      remove_column :yellow_ribbon_program_sources, :school_name_in_yr_database, :string
      remove_column :yellow_ribbon_program_sources, :sco_email_address, :string
      remove_column :yellow_ribbon_program_sources, :sco_name, :string
      remove_column :yellow_ribbon_program_sources, :sco_telephone_number, :string
      remove_column :yellow_ribbon_program_sources, :sfr_email_address, :string
      remove_column :yellow_ribbon_program_sources, :sfr_name, :string
      remove_column :yellow_ribbon_program_sources, :sfr_telephone_number, :string
      remove_column :yellow_ribbon_program_sources, :updated_for_2011_2012, :boolean
      remove_column :yellow_ribbon_program_sources, :withdrawn, :boolean

      # Remove columns from yellow_ribbon_programs
      remove_column :yellow_ribbon_programs, :street_address, :string
      remove_column :yellow_ribbon_programs, :zip, :string
      remove_column :yellow_ribbon_programs, :amendment_date, :date
      remove_column :yellow_ribbon_programs, :consolidated_agreement, :boolean
      remove_column :yellow_ribbon_programs, :date_yr_signed_by_yr_official, :date
      remove_column :yellow_ribbon_programs, :date_confirmation_sent, :date
      remove_column :yellow_ribbon_programs, :flight_school, :boolean
      remove_column :yellow_ribbon_programs, :ineligible, :boolean
      remove_column :yellow_ribbon_programs, :initials_yr_processor, :string
      remove_column :yellow_ribbon_programs, :missed_deadline, :boolean
      remove_column :yellow_ribbon_programs, :modified, :boolean
      remove_column :yellow_ribbon_programs, :new_school, :boolean
      remove_column :yellow_ribbon_programs, :notes, :text
      remove_column :yellow_ribbon_programs, :open_ended_agreement, :boolean
      remove_column :yellow_ribbon_programs, :public_private, :string
      remove_column :yellow_ribbon_programs, :school_name_in_weams, :string
      remove_column :yellow_ribbon_programs, :school_name_in_yr_database, :string
      remove_column :yellow_ribbon_programs, :sco_email_address, :string
      remove_column :yellow_ribbon_programs, :sco_name, :string
      remove_column :yellow_ribbon_programs, :sco_telephone_number, :string
      remove_column :yellow_ribbon_programs, :sfr_email_address, :string
      remove_column :yellow_ribbon_programs, :sfr_name, :string
      remove_column :yellow_ribbon_programs, :sfr_telephone_number, :string
      remove_column :yellow_ribbon_programs, :updated_for_2011_2012, :boolean
      remove_column :yellow_ribbon_programs, :withdrawn, :boolean
    }
  end
end
