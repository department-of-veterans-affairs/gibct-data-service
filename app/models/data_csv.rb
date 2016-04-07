class DataCsv < ActiveRecord::Base
  # GIBCT uses field called type, must kludge to prevent STI
  self.inheritance_column = "inheritance_type"

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
    query_str += Weam.select(names).where(approved: true).to_sql + ")"    

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

  ###########################################################################
  ## update_with_sva
  ## Updates the DataCsv table with data from the sva table.
  ###########################################################################
  def self.update_with_sva
    names = Sva::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += "student_veteran = TRUE, "
    query_str += names.map { |name| %("#{name}" = svas.#{name}) }.join(', ')

    query_str += ' FROM svas '
    query_str += 'WHERE data_csvs.cross = svas.cross '
    query_str += 'AND svas.cross IS NOT NULL'    

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_vsoc
  ## Updates the DataCsv table with data from the vsoc table.
  ###########################################################################
  def self.update_with_vsoc
    names = Vsoc::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = vsocs.#{name}) }.join(', ')

    query_str += ' FROM vsocs '
    query_str += 'WHERE data_csvs.facility_code = vsocs.facility_code'    

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_eight_key
  ## Updates the DataCsv table with data from the eight_keys table.
  ###########################################################################
  def self.update_with_eight_key
    names = EightKey::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += "eight_keys = TRUE "
    query_str += ' FROM eight_keys '
    query_str += 'WHERE data_csvs.cross = eight_keys.cross '
    query_str += 'AND eight_keys.cross IS NOT NULL'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_accreditation
  ## Updates the DataCsv table with data from the accreditations table.
  ###########################################################################
  def self.update_with_accreditation
    names = Accreditation::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = accreditations.#{name}) }.join(', ')
    query_str += ' FROM accreditations '
    query_str += 'WHERE data_csvs.cross = accreditations.cross '
    query_str += %(AND accreditations.periods LIKE '%current%' )
    query_str += "AND accreditations.csv_accreditation_type = 'institutional' "
    query_str += 'AND accreditations.cross IS NOT NULL'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_arf_gibill
  ## Updates the DataCsv table with data from the arf_gibills table.
  ###########################################################################
  def self.update_with_arf_gibill
    names = ArfGibill::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = arf_gibills.#{name}) }.join(', ')
    query_str += ' FROM arf_gibills '
    query_str += 'WHERE data_csvs.facility_code = arf_gibills.facility_code'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_p911_tf
  ## Updates the DataCsv table with data from the p911_tfs table.
  ###########################################################################
  def self.update_with_p911_tf
    names = P911Tf::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = p911_tfs.#{name}) }.join(', ')
    query_str += ' FROM p911_tfs '
    query_str += 'WHERE data_csvs.facility_code = p911_tfs.facility_code'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_p911_yr
  ## Updates the DataCsv table with data from the p911_yrs table.
  ###########################################################################
  def self.update_with_p911_yr
    names = P911Yr::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = p911_yrs.#{name}) }.join(', ')
    query_str += ' FROM p911_yrs '
    query_str += 'WHERE data_csvs.facility_code = p911_yrs.facility_code'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_mou
  ## Updates the DataCsv table with data from the mous table.
  ###########################################################################
  def self.update_with_mou
    names = Mou::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = mous.#{name}) }.join(', ')
    query_str += ' FROM mous '
    query_str += 'WHERE data_csvs.ope6 = mous.ope6'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_scorecard
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_scorecard
    names = Scorecard::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = scorecards.#{name}) }.join(', ')
    query_str += ' FROM scorecards '
    query_str += 'WHERE data_csvs.cross = scorecards.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_ic
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_ic
    names = IpedsIc::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = ipeds_ics.#{name}) }.join(', ')
    query_str += ' FROM ipeds_ics '
    query_str += 'WHERE data_csvs.cross = ipeds_ics.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_hd
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_hd
    names = IpedsHd::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = ipeds_hds.#{name}) }.join(', ')
    query_str += ' FROM ipeds_hds '
    query_str += 'WHERE data_csvs.cross = ipeds_hds.cross'

    run_bulk_query(query_str)
  end

  ###########################################################################
  ## update_with_ipeds_ic_ay
  ## Updates the DataCsv table with data from the scorecards table.
  ###########################################################################
  def self.update_with_ipeds_ic_ay
    names = IpedsIcAy::USE_COLUMNS.map(&:to_s)

    query_str = 'UPDATE data_csvs SET '
    query_str += names.map { |name| %("#{name}" = ipeds_ic_ays.#{name}) }.join(', ')
    query_str += ' FROM ipeds_ic_ays '
    query_str += 'WHERE data_csvs.cross = ipeds_ic_ays.cross'

    run_bulk_query(query_str)
  end
end
