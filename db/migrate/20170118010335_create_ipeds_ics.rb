class CreateIpedsIcs < ActiveRecord::Migration
  def change
    create_table :ipeds_ics do |t|
      # Used in the building of DataCsv
      t.string :cross, null: false
      t.boolean :credit_for_mil_training
      t.boolean :vet_poc
      t.boolean :student_vet_grp_ipeds
      t.boolean :soc_member
      t.string :calendar
      t.boolean :online_all
      t.integer :calsys, null: false
      t.integer :distnced, null: false
      t.integer :vet2, null: false
      t.integer :vet3, null: false
      t.integer :vet4, null: false
      t.integer :vet5, null: false

      # Not used in building DataCsv, but used in exporting source csv
      t.integer :peo1istr
      t.integer :peo2istr
      t.integer :peo3istr
      t.integer :peo4istr
      t.integer :peo5istr
      t.integer :peo6istr
      t.integer :cntlaffi
      t.integer :pubprime
      t.integer :pubsecon
      t.integer :relaffil
      t.integer :level1
      t.integer :level2
      t.integer :level3
      t.integer :level4
      t.integer :level5
      t.integer :level6
      t.integer :level7
      t.integer :level8
      t.integer :level12
      t.integer :level17
      t.integer :level18
      t.integer :level19
      t.integer :openadmp
      t.integer :credits1
      t.integer :credits2
      t.integer :credits3
      t.integer :credits4
      t.integer :slo5
      t.integer :slo51
      t.integer :slo52
      t.integer :slo53
      t.integer :slo6
      t.integer :slo7
      t.integer :slo8
      t.integer :slo81
      t.integer :slo82
      t.integer :slo83
      t.integer :slo9
      t.integer :yrscoll
      t.integer :stusrv1
      t.integer :stusrv2
      t.integer :stusrv3
      t.integer :stusrv4
      t.integer :stusrv8
      t.integer :stusrv9
      t.integer :libfac
      t.integer :athassoc
      t.integer :assoc1
      t.integer :assoc2
      t.integer :assoc3
      t.integer :assoc4
      t.integer :assoc5
      t.integer :assoc6
      t.integer :sport1
      t.integer :confno1
      t.integer :sport2
      t.integer :confno2
      t.integer :sport3
      t.integer :confno3
      t.integer :sport4
      t.integer :confno4
      t.string :xappfeeu
      t.integer :applfeeu
      t.string :xappfeeg
      t.integer :applfeeg
      t.integer :ft_ug
      t.integer :ft_ftug
      t.integer :ftgdnidp
      t.integer :pt_ug
      t.integer :pt_ftug
      t.integer :ptgdnidp
      t.integer :docpp
      t.integer :docppsp
      t.integer :tuitvary
      t.integer :room
      t.integer :xroomcap
      t.integer :roomcap
      t.integer :board
      t.string :xmealswk
      t.integer :mealswk
      t.string :xroomamt
      t.integer :roomamt
      t.string :xbordamt
      t.integer :boardamt
      t.string :xrmbdamt
      t.integer :rmbrdamt
      t.integer :alloncam
      t.integer :tuitpl
      t.integer :tuitpl1
      t.integer :tuitpl2
      t.integer :tuitpl3
      t.integer :tuitpl4
      t.integer :disab
      t.string :xdisabpc
      t.integer :disabpct
      t.integer :dstnced1
      t.integer :dstnced2
      t.integer :dstnced3
      t.integer :vet1
      t.integer :vet9
      t.timestamps null: false

      t.index :cross
    end
  end
end
