# frozen_string_literal: true

namespace :accreditation_types do
  # Initial seed for accreditation types. This should be run after the db:migrate command.
  desc 'Seeds accreditation type keywords for accreditation types'
  task seed_keywords: :environment do
    AccreditationTypeKeyword.destroy_all
    AccreditationTypeKeyword.create!(
      [
        { accreditation_type: 'regional', keyword_match: 'middle' },
        { accreditation_type: 'regional', keyword_match: 'new england' },
        { accreditation_type: 'regional', keyword_match: 'north central' },
        { accreditation_type: 'regional', keyword_match: 'southern' },
        { accreditation_type: 'regional', keyword_match: 'western' },
        { accreditation_type: 'regional', keyword_match: 'higher learning commission' },
        { accreditation_type: 'regional', keyword_match: 'wasc' },
        { accreditation_type: 'regional', keyword_match: 'northwest' },

        { accreditation_type: 'national', keyword_match: 'career schools' },
        { accreditation_type: 'national', keyword_match: 'continuing education' },
        { accreditation_type: 'national', keyword_match: 'independent colleges' },
        { accreditation_type: 'national', keyword_match: 'biblical' },
        { accreditation_type: 'national', keyword_match: 'occupational' },
        { accreditation_type: 'national', keyword_match: 'distance' },
        { accreditation_type: 'national', keyword_match: 'new york' },
        { accreditation_type: 'national', keyword_match: 'transnational' },

        { accreditation_type: 'hybrid', keyword_match: 'acupuncture' },
        { accreditation_type: 'hybrid', keyword_match: 'nursing' },
        { accreditation_type: 'hybrid', keyword_match: 'health education' },
        { accreditation_type: 'hybrid', keyword_match: 'liberal' },
        { accreditation_type: 'hybrid', keyword_match: 'legal' },
        { accreditation_type: 'hybrid', keyword_match: 'funeral' },
        { accreditation_type: 'hybrid', keyword_match: 'osteopathic' },
        { accreditation_type: 'hybrid', keyword_match: 'pediatric' },
        { accreditation_type: 'hybrid', keyword_match: 'theological' },
        { accreditation_type: 'hybrid', keyword_match: 'massage' },
        { accreditation_type: 'hybrid', keyword_match: 'radiologic' },
        { accreditation_type: 'hybrid', keyword_match: 'midwifery' },
        { accreditation_type: 'hybrid', keyword_match: 'montessori' },
        { accreditation_type: 'hybrid', keyword_match: 'career arts' },
        { accreditation_type: 'hybrid', keyword_match: 'design' },
        { accreditation_type: 'hybrid', keyword_match: 'dance' },
        { accreditation_type: 'hybrid', keyword_match: 'music' },
        { accreditation_type: 'hybrid', keyword_match: 'theatre' },
        { accreditation_type: 'hybrid', keyword_match: 'chiropractic' }
      ]
    )
  end
end
