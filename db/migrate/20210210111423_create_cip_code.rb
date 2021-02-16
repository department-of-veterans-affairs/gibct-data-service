class CreateCipCode < ActiveRecord::Migration[5.2]
    def change
        create_table :cip_codes do |t|
            t.string :cip_family
            t.string :cip_code
            t.string :action
            t.boolean :text_change
            t.string :cip_title
            t.string :cip_definition
            t.string :cross_references
            t.string :examples
        end    
    end    
end  