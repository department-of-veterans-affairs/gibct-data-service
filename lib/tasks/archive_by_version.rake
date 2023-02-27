# frozen_string_literal: true

# What has been observed is that sometimes publishing to production times out
# on deleting insitutions and dependent rows. It's all wrapped in a transaction
# online and this causes two problems. Rows don't get archived and the insitutions
# and related data tables get filled up with data from obsolete versions. This
# task is for cleaning that up when it happens. Note that access to a production
# gibct instance is needed to run the rake task at the command line inside the
# docker instance. In conjunction with this task, the online process was tweaked
# to increase the timeout parameter and use with_batches as part of the deleting
# process.

desc 'task to archive institutions and related tables by version'
task :archive_by_version, [:version_id] => [:environment] do |_t, args|
  version_id = args[:version_id]
  archive_version(version_id)
end

def archive_version(version_id)
  ApplicationRecord.transaction do
    ActiveRecord::Base.connection.execute("SET LOCAL statement_timeout = '600000'")
    Archiver::ARCHIVE_TYPES.each do |archivable|
      create_archives(archivable[:source], archivable[:archive], version_id)
      source = set_source(archivable)
      puts "deleting from #{archivable[:source]}"
      source.where('versions.id = ?', version_id).in_batches.delete_all
    end
  rescue StandardError => e
    puts "There was an error #{e.message}"
  end
end

def create_archives(source, archive, version_id)
  return if archive.blank?

  cols = archive.column_names
  insert_cols = (cols.map { |col| '"' + col + '"' }).join(', ')
  select_cols = (cols.map { |col| 's.' + col }).join(', ')

  str = "INSERT INTO #{archive.table_name}(#{insert_cols}) SELECT #{select_cols} FROM #{source.table_name} s "

  join1 = 'JOIN institutions i ON s.institution_id = i.id JOIN versions v ON i.version_id = v.id'
  join2 = 'JOIN versions v ON s.version_id = v.id'
  str += source.has_attribute?(:institution_id) ? join1 : join2
  str += ' WHERE v.id = ?;'
  sql = archive.send(:sanitize_sql_for_conditions, [str, version_id])

  puts "inserting rows into #{archive}"
  ApplicationRecord.connection.execute(sql)
end

def set_source(archivable)
  return archivable[:source].joins(institution: :version) if archivable[:source].has_attribute?(:institution_id)

  archivable[:source].joins(:version)
end
