class CreateZipcodeRatesArchive < ActiveRecord::Migration
  def up
    safety_assured do
      execute "create table zipcode_rates_archives (like zipcode_rates
        including defaults
        including constraints
        including indexes
    );"
    end
  end

   def down
    drop_table :zipcode_rates_archives
  end
end
