# frozen_string_literal: true

class InstitutionCategoryRating < ApplicationRecord
  belongs_to :version

  def self.build_for_category(version_id, category)
    sql = <<-SQL
      INSERT INTO institution_category_ratings (
        institution_id,
        version_id,
        category_name,
        rated1_count,
        rated2_count,
        rated3_count,
        rated4_count,
        rated5_count,
        na_count,
        average_rating,
        total_count
      )
      SELECT
        institutions.id,
        #{version_id},
        '#{category}',
        SUM(CASE #{category} WHEN 1 THEN 1 ELSE 0 END),
        SUM(CASE #{category} WHEN 2 THEN 1 ELSE 0 END),
        SUM(CASE #{category} WHEN 3 THEN 1 ELSE 0 END),
        SUM(CASE #{category} WHEN 4 THEN 1 ELSE 0 END),
        SUM(CASE #{category} WHEN 5 THEN 1 ELSE 0 END),
        SUM(CASE WHEN #{category} IS NULL THEN 1 ELSE 0 END),
        (SUM(CASE #{category} WHEN 1 THEN 1 ELSE 0 END)
         + SUM(CASE #{category} WHEN 2 THEN 2 ELSE 0 END)
         + SUM(CASE #{category} WHEN 3 THEN 3 ELSE 0 END)
         + SUM(CASE #{category} WHEN 4 THEN 4 ELSE 0 END)
         + SUM(CASE #{category} WHEN 5 THEN 5 ELSE 0 END)) / COUNT(institutions.id)::float,
        COUNT(#{category})
      FROM institutions
        INNER JOIN 
        (
          SELECT 
            facility_code vote_facility_code,
            #{category},
            row_num
          FROM
            (
              SELECT
                facility_code,
                #{category},
                ROW_NUMBER() OVER (PARTITION BY rater_id ORDER BY rated_at DESC ) AS row_num
              FROM school_ratings
            ) top_votes
          WHERE row_num = 1
        ) votes ON institutions.facility_code = vote_facility_code
      WHERE version_id = #{version_id}
      GROUP BY institutions.id
    SQL

    connection.execute(send(:sanitize_sql_for_conditions, [sql]))
  end
end
