class Lcpe::PreloadDataset < ApplicationRecord
  # ['Lcpe::Lac', 'Lcpe::Exam']
  LCPE_TYPES = Lcpe::Feed.normalized_klasses.freeze

  validates :subject_class, presence: true, inclusion: { in: LCPE_TYPES }

  scope :of_type, ->(lcpe_type) { where(subject_class: lcpe_type).order(created_at: :desc) }
  scope :stale, ->(lcpe_type) { of_type(lcpe_type).offset(1) }

  def self.fresh(lcpe_type)
    of_type(lcpe_type).first
  end

  def self.build(lcpe_type)
    # wipe all exepct most recent preload for lcpe type
    stale(lcpe_type).destroy_all
    create(subject_class: lcpe_type).tap do |preload|
      dataset = preload.klass.with_enriched_id
      preload.update(body: dataset.to_json)
    end
  end

  def klass
    subject_class.constantize
  end
end
