class AddIndexForStemOfferedOnInstitutions < ActiveRecord::Migration
  disable_ddl_transaction!
  
  def change
    add_index :institutions, :stem_offered, algorithm: :concurrently
  end
end
