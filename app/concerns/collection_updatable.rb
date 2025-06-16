# frozen_string_literal: true

# Shared update logic for GIDS forms which iterate over entire collection
#  - e.g. Calculator Constants and Rate Adjustments
module CollectionUpdatable
  extend ActiveSupport::Concern

  included do
    before_action :set_collection_params, only: :update
  end

  private

  # Iterates over collection and updates records if changes present
  # Accepts optional block to transform output (e.g. record.name or record.id)
  # Returns array of IDs for updated records
  def update_collection
    updated = []
    @collection_params.each do |id, attrs|
      record = klass.find(id)
      record.assign_attributes(attrs)
      # Only update records for which changes are present
      next unless record.changed?

      record.save
      updated << (block_given? ? yield(record) : record)
    end
    updated
  end

  def set_collection_params
    permitted = {}
    # e.g. { '1' => [:benefit_type, :rate] }
    klass.pluck(:id).each { |id| permitted[id.to_s] = updatable_fields }
    @collection_params = params.require(controller_name).permit(permitted)
  end

  def updatable_fields
    excepted = %w[id created_at updated_at]
    klass.column_names
         .reject { |col| excepted.include?(col) }
         .map(&:to_sym)
  end

  def klass
    Object.const_get(controller_name.classify)
  end
end
