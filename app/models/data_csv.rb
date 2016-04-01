class DataCsv < ActiveRecord::Base
  validates :facility_code, presence: true, uniqueness: true
  validates :institution, presence: true

  validates :state, inclusion: { in: DS::State.get_names }, allow_blank: true

  ###########################################################################
  ## run_bulk_query
  ## Runs bulk query and provides support for created_at, updated_at, and
  ## renumbering autoincrements.
  ###########################################################################
  def self.run_bulk_query(query, create = false, restart = false)
    str = restart ? "ALTER SEQUENCE data_csvs_id_seq RESTART WITH 1; " : ""

    str += "ALTER TABLE data_csvs ALTER COLUMN updated_at SET DEFAULT now(); "
    str += query + ";"
    str += "ALTER TABLE data_csvs ALTER COLUMN updated_at DROP DEFAULT; "

    if create
      str = "ALTER TABLE data_csvs ALTER COLUMN created_at SET DEFAULT now(); " + str
      str += " ALTER TABLE data_csvs ALTER COLUMN created_at DROP DEFAULT; "
    end

    ActiveRecord::Base.connection.execute(str)
  end

  ###########################################################################
  ## initialize_with_weams
  ## Initializes the DataCsv table with data from approved weams schools.
  ###########################################################################
  def self.initialize_with_weams
    DataCsv.delete_all

    names = Weam::USE_COLUMNS.map(&:to_s).join(', ')

    query_str = "INSERT INTO data_csvs (#{names}) ("
    query_str += Weam.select(names).approved.to_sql + ")"    

    run_bulk_query(query_str, true, true)
  end

  ###########################################################################
  ## update_with_crosswalk
  ## Updates the DataCsv table with data from the crosswalk.
  ###########################################################################
  def self.update_with_crosswalk
    names = VaCrosswalk::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = va_crosswalks.#{name}) }.join(', ')

    query_str += ' FROM va_crosswalks '
    query_str += 'WHERE data_csvs.facility_code = va_crosswalks.facility_code'    

    run_bulk_query(query_str)
  end
end
