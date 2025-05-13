# frozen_string_literal: true

class VersionedComplaint < ApplicationRecord
  belongs_to :version

  scope :closed, -> { where(status: 'closed').where.not(closed_reason: ['invalid','',nil]) }

  # A complaint can have multiple categories. These are originally derived
  # from the `issues` field, which is just a string of complaint types. This
  # field is then used to populate the cfbfc, cqbfc, crbfc, etc. fields by
  # flipping those to a '1' instead of a '0'. Here we are using these fields
  # to build a list of human-readable categories.
  def categories
    {
      cfbfc: 'financial',
      cqbfc: 'quality',
      crbfc: 'refund',
      cmbfc: 'marketing',
      cabfc: 'accreditation',
      cdrbfc: 'degree_requirements',
      cslbfc: 'student_loans',
      cgbfc: 'grades',
      cctbfc: 'credit_transfer',
      cjbfc: 'job',
      ctbfc: 'transcript',
      cobfc: 'other'
    }.filter { |k,_| send(k) == 1 }.values
  end
end
