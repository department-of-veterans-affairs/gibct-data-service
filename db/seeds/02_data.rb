require 'seed_utils'

if ENV['CI'].blank?

  user = User.first

  puts 'Deleting old uploads data'
  Upload.delete_all

  puts 'Deleting old Versioned SCOs'
  VersionedSchoolCertifyingOfficial.delete_all

  puts 'Deleting old Caution Flags'
  CautionFlag.delete_all

  puts 'Deleting old institutions'
  Institution.delete_all

  puts 'Deleting old institution programs'
  InstitutionProgram.delete_all

  puts 'Deleting old institution category ratings'
  InstitutionCategoryRating.delete_all

  puts 'Deleting old zipcode rates'
  ZipcodeRate.delete_all

  puts 'Deleting old constants'
  CalculatorConstant.delete_all

  puts 'Deleting old crosswalk issues'
  CrosswalkIssue.delete_all

  puts 'Deleting old versions'
  Version.delete_all

  puts 'Loading CSVs. Why not do some calf raises while you wait? ...' 
  SeedUtils.seed_tables_with_group('Accreditation', user)
  SeedUtils.seed_table_with_upload(AccreditationAction, user)
  SeedUtils.seed_table_with_upload(AccreditationInstituteCampus, user)
  SeedUtils.seed_table_with_upload(AccreditationRecord, user)
  SeedUtils.seed_table_with_upload(ArfGiBill, user)
  SeedUtils.seed_table_with_upload(CalculatorConstant, user)
  SeedUtils.seed_table_with_upload(CipCode, user)
  SeedUtils.seed_table_with_upload(Complaint, user, skip_lines: 0)
  SeedUtils.seed_table_with_upload(Crosswalk, user)
  SeedUtils.seed_table_with_upload(EightKey, user, skip_lines: 0)
  SeedUtils.seed_table_with_upload(EduProgram, user)
  SeedUtils.seed_table_with_upload(Hcm, user, skip_lines: 0)
  SeedUtils.seed_table_with_upload(IpedsCipCode, user)
  SeedUtils.seed_table_with_upload(IpedsHd, user)
  SeedUtils.seed_table_with_upload(IpedsIc, user)
  SeedUtils.seed_table_with_upload(IpedsIcAy, user)
  SeedUtils.seed_table_with_upload(IpedsIcPy, user)
  SeedUtils.seed_table_with_upload(Mou, user, skip_lines: 0)
  SeedUtils.seed_table_with_upload(Outcome, user)
  SeedUtils.seed_table_with_upload(Post911Stat, user)
  SeedUtils.seed_table_with_upload(Program, user)
  SeedUtils.seed_table_with_upload(SchoolCertifyingOfficial, user)
  SeedUtils.seed_table_with_upload(SchoolRating, user)
  SeedUtils.seed_table_with_upload(Scorecard, user)
  SeedUtils.seed_table_with_upload(ScorecardDegreeProgram, user)
  SeedUtils.seed_table_with_upload(Sec103, user)
  SeedUtils.seed_table_with_upload(Sec109ClosedSchool, user)
  SeedUtils.seed_table_with_upload(Sec702, user)
  SeedUtils.seed_table_with_upload(StemCipCode, user)
  SeedUtils.seed_table_with_upload(Sva, user)
  SeedUtils.seed_table_with_upload(VaCautionFlag, user)
  SeedUtils.seed_table_with_upload(Vsoc, user)
  SeedUtils.seed_table_with_upload(Weam, user)
  SeedUtils.seed_table_with_upload(YellowRibbonProgramSource, user)
  SeedUtils.seed_table_with_upload(VrrapProvider, user, {},'xlsx')
end


