# frozen_string_literal: true

# This utility model is primarily intended to be used in your local development environment
# but can also be used in the va development and staging environments to clean up and tune
# the tables involved in generating a preview. It was observed that after a while the indexes
# get out of whack and performance really degrades because table scans wind up getting used
# to access the data instead of indexes.
class DbCleanup
  # Child tables of versions
  TABLES = %w[ caution_flags institution_programs versioned_school_certifying_officials
               yellow_ribbon_programs institutions zipcode_rates].freeze

  SIMPLE_DELETE_TABLES = %w[caution_flags institutions zipcode_rates].freeze

  def self.vacuum_and_analyze_preview_tables
    TABLES.each { |table| vacuum_and_analyze(table) }
    vacuum_and_analyze('versions')
  end

  def self.delete_broken_preview(version_id)
    TABLES.each { |table| delete_version_and_vacuum(table, version_id) }

    puts "Deleting version #{version_id}"
    sql = Version.send(:sanitize_sql, ["DELETE FROM versions WHERE id= #{version_id}"])
    ActiveRecord::Base.connection.execute(sql)
    vacuum_and_analyze('versions')
  end

  def self.vacuum_and_analyze(table)
    puts "Vacuuming #{table}"
    sql = Version.send(:sanitize_sql, ["VACUUM FULL ANALYZE #{table}"])
    ActiveRecord::Base.connection.execute(sql)
  end

  def self.delete_version_and_vacuum(table, version_id)
    sql1 = "DELETE FROM #{table} WHERE version_id = #{version_id}"
    sql2 = "DELETE FROM #{table} WHERE institution_id in " \
           "(select id from institutions where version_id = #{version_id})"

    puts "deleting rows from #{table} for version #{version_id}"

    unsanitized_sql = sql1
    unsanitized_sql = sql2 unless SIMPLE_DELETE_TABLES.include?(table)

    sql = Version.send(:sanitize_sql, [unsanitized_sql])
    ActiveRecord::Base.connection.execute(sql)

    vacuum_and_analyze(table)
  end
end
