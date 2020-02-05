# frozen_string_literal: true

class RenameDevIndexes < ActiveRecord::Migration[5.2]
  def up
    institutions_indexes = ActiveRecord::Base.connection.indexes('institutions').map(&:name)
    if institutions_indexes.include?('institutions_temp_lower_idx1')
      rename_index :institutions, 'institutions_temp_lower_idx1', 'index_institutions_institution_lprefix'
    end

    if index_exists?(:institutions, :address_1, name: 'institutions_temp_address_1_idx1')
      rename_index :institutions, 'institutions_temp_address_1_idx1', 'index_institutions_on_address_1'
    end

    if index_exists?(:institutions, :address_2, name: 'institutions_temp_address_2_idx1')
      rename_index :institutions, 'institutions_temp_address_2_idx1', 'index_institutions_on_address_2'
    end

    if index_exists?(:institutions, :address_3, name: 'institutions_temp_address_3_idx1')
      rename_index :institutions, 'institutions_temp_address_3_idx1', 'index_institutions_on_address_3'
    end

    if index_exists?(:institutions, :city, name: 'institutions_temp_city_idx1')
      rename_index :institutions, 'institutions_temp_city_idx1', 'index_institutions_on_city'
    end

    if index_exists?(:institutions, :cross, name: 'institutions_temp_cross_idx1')
      rename_index :institutions, 'institutions_temp_cross_idx1', 'index_institutions_on_cross'
    end

    if index_exists?(:institutions, :distance_learning, name: 'institutions_temp_distance_learning_idx1')
      rename_index :institutions, 'institutions_temp_distance_learning_idx1', 'index_institutions_on_distance_learning'
    end

    if index_exists?(:institutions, :facility_code, name: 'institutions_temp_facility_code_idx1')
      rename_index :institutions, 'institutions_temp_facility_code_idx1', 'index_institutions_on_facility_code'
    end

    if index_exists?(:institutions, :institution, name: 'institutions_temp_institution_idx1')
      rename_index :institutions, 'institutions_temp_institution_idx1', 'index_institutions_on_institution'
    end

    if index_exists?(:institutions, :institution_type_name, name: 'institutions_temp_institution_type_name_idx1')
      rename_index(:institutions,
                   'institutions_temp_institution_type_name_idx1',
                   'index_institutions_on_institution_type_name')
    end

    if index_exists?(:institutions, :online_only, name: 'institutions_temp_online_only_idx1')
      rename_index :institutions, 'institutions_temp_online_only_idx1', 'index_institutions_on_online_only'
    end

    if index_exists?(:institutions, :ope, name: 'institutions_temp_ope_idx1')
      rename_index :institutions, 'institutions_temp_ope_idx1', 'index_institutions_on_ope'
    end

    if index_exists?(:institutions, :ope6, name: 'institutions_temp_ope6_idx1')
      rename_index :institutions, 'institutions_temp_ope6_idx1', 'index_institutions_on_ope6'
    end

    if index_exists?(:institutions, :state, name: 'institutions_temp_state_idx1')
      rename_index :institutions, 'institutions_temp_state_idx1', 'index_institutions_on_state'
    end

    if index_exists?(:institutions, :stem_offered, name: 'institutions_temp_stem_offered_idx1')
      rename_index :institutions, 'institutions_temp_stem_offered_idx1', 'index_institutions_on_stem_offered'
    end

    if index_exists?(:institutions,
                     %i[version parent_facility_code_id],
                     name: 'institutions_temp_version_parent_facility_code_id_idx1')
      rename_index(:institutions,
                   'institutions_temp_version_parent_facility_code_id_idx1',
                   'index_institutions_on_version_and_parent_facility_code_id')
    end

    if index_exists?(:institutions, :version, name: 'institutions_temp_version_idx1')
      rename_index :institutions, 'institutions_temp_version_idx1', 'index_institutions_on_version'
    end
  end
  
end
