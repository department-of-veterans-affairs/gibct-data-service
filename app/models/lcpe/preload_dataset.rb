class Lcpe::PreloadDataset < ApplicationRecord
  LCPE_TYPES = %w[Lcpe::Lac Lcpe::Exam].freeze

  validates :subject_class, presence: true, inclusion: { in: LCPE_TYPES }

  scope :by_type, ->(lcpe_type) { where(subject_class: lcpe_type) }

  def self.fresh_by_type(lcpe_type)
    Lcpe::PreloadDataset
      .by_type(lcpe_type)
      .order(created_at: :desc).first
  end

  # is it necessary to clean up body of stale preloads?
  def build!
    freshest&.update(body:nil) unless fresh?

    data = lcpe_klass.with_enriched_id
    update(body: data.to_json)
    
    save!
  end

  def freshest
    @freshest ||= Lcpe::PreloadDataset.fresh_by_type(subject_class)
  end

  def fresh?
    self == freshest
  end

  private

  def lcpe_klass
    subject_class.constantize
  end
end
