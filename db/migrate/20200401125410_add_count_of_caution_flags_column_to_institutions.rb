class AddCountOfCautionFlagsColumnToInstitutions < ActiveRecord::Migration[5.2]
  # run on rails console to update counter cache
  #Institution.find_each {|institutions| Institution.reset_counters(institutions.id, :caution_flags)}
  def change
      add_column :institutions, :count_of_caution_flags, :integer, :default => 0
    end
  
  end