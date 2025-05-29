# frozen_string_literal: true

# Shared update logic for GIDS forms which cover entire collection
module CollectionUpdatable
  extend ActiveSupport::Concern

  # Iterates over collection and updates records if changes present
  # Returns array of IDs for updated records
  def update
    updated = []
    collection_params.each do |id, attrs|
      record = klass.find(id)
      # Only update records for which changes are present
      record.assign_attributes(attrs)
      if record.changed?
        record.save
        updated.push(id)
      end
    end
    updated
  end

  private

  def collection_params
    permitted = {}
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
