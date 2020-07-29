class ChangeVaCautionFlagDateType < ActiveRecord::Migration[4.2]
    def change
      drop_table :va_caution_flags
      create_table :va_caution_flags do |t|
        t.string :facility_code, null: false
        t.string :institution_name
        t.string :school_system_name
        t.string :settlement_title
        t.string :settlement_description
        t.string :settlement_date
        t.string :settlement_link
        t.string :school_closing_date
        t.boolean :sec_702
      end
    end
end