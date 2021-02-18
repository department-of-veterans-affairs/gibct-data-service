class CreateScorecardDegreeProgram < ActiveRecord::Migration[5.2]
    def change
        create_table :scorecard_degree_programs do |t|
          t.integer :unitid
          t.string :ope6_id
          t.integer :control
          t.integer :main
          t.string :cip_code
          t.string :cip_desc
          t.integer :cred_lev
          t.string :cred_desc
        end    
    end    
end
