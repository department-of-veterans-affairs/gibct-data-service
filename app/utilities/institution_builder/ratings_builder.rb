# frozen_string_literal: true

module InstitutionBuilder
  class RatingsBuilder
    extend Common

    def self.build_institution_category_ratings_for_category(version_id, category)
      sql = <<-SQL
        INSERT INTO institution_category_ratings (
          institution_id,
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
          '#{category}',
          SUM(CASE #{category} WHEN 1 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 2 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 3 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 4 THEN 1 ELSE 0 END),
          SUM(CASE #{category} WHEN 5 THEN 1 ELSE 0 END),
          SUM(CASE WHEN #{category} IS NULL THEN 1 ELSE 0 END),
          CASE
            WHEN COUNT(#{category}) = 0 THEN NULL
          ELSE
          (SUM(CASE #{category} WHEN 1 THEN 1 ELSE 0 END)
           + SUM(CASE #{category} WHEN 2 THEN 2 ELSE 0 END)
           + SUM(CASE #{category} WHEN 3 THEN 3 ELSE 0 END)
           + SUM(CASE #{category} WHEN 4 THEN 4 ELSE 0 END)
           + SUM(CASE #{category} WHEN 5 THEN 5 ELSE 0 END)) / COUNT(#{category})::float
          END,
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
                  CASE
                    WHEN #{category} <= 0 THEN null
                    WHEN #{category} > 5 THEN 5
                    ELSE #{category}
                  END,
                  ROW_NUMBER() OVER (PARTITION BY rater_id ORDER BY rated_at DESC ) AS row_num
                FROM school_ratings
              ) top_votes
            WHERE row_num = 1
          ) votes ON institutions.facility_code = vote_facility_code
        WHERE version_id = #{version_id}
        GROUP BY institutions.id
      SQL

      InstitutionCategoryRating.connection.execute(InstitutionCategoryRating.send(:sanitize_sql_for_conditions, [sql]))
    end

    def self.build(version_id)
      InstitutionCategoryRating::RATING_CATEGORY_COLUMNS.each do |category_column|
        build_institution_category_ratings_for_category(version_id, category_column)
      end

      sql = <<-SQL
        UPDATE institutions
        SET rating_average = ratings.average, rating_count = ratings.count
        FROM(
          SELECT
            institution_id,
            CASE
              WHEN SUM(rated5_count) + SUM(rated4_count) + SUM(rated3_count)
                + SUM(rated2_count) + SUM(rated1_count) = 0 THEN NULL::float
            ELSE
            (SUM(rated5_count) * 5 + SUM(rated4_count) * 4 + SUM(rated3_count) * 3
              + SUM(rated2_count) * 2 + SUM(rated1_count))
              / (SUM(rated5_count) + SUM(rated4_count) + SUM(rated3_count)
              + SUM(rated2_count) + SUM(rated1_count))::float
            END average,
            COUNT(DISTINCT rater_id) count
          FROM institution_category_ratings
            INNER JOIN institutions ON institution_category_ratings.institution_id = institutions.id
              AND institutions.version_id = #{version_id}
            INNER JOIN school_ratings ON institutions.facility_code = school_ratings.facility_code
          group by institution_id
        ) ratings
        WHERE id = ratings.institution_id
        AND version_id = #{version_id}
      SQL

      Institution.connection.update(sql)
    end
  end
end
