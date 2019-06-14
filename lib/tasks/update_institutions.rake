# frozen_string_literal: true

require 'seed_utils'

# Define `table_name` in a custom named class to make sure that you run on the
# same table you had during the creation of the migration.
# In future if you override the `Institution` class and change the `table_name`,
# it won't break the migration or cause serious data corruption.
class InstitutionModel < ActiveRecord::Base
  self.table_name = :institutions
end

class AddColumnApprovedToInstitutions < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        InstitutionModel.update_all(approved: true)
      end
    end
  end
end

namespace :db do
  desc 'Updates institutions column approved to true for records existing before 6/14/19'
  task update_institutions: :environment do
    AddColumnApprovedToInstitutions.new.change
  end
end
