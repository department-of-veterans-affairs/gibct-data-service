class AddIndexForStemOfferedOnInstitutions < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!
  
  def change
    add_index :institutions, :stem_offered, algorithm: :concurrently
  end
end
