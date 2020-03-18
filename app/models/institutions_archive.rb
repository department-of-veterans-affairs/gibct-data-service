# frozen_string_literal: true

class InstitutionsArchive < Institution
  self.table_name = 'institutions_archives'

  # method is to support frontend until has been switched over to using caution_flags attribute
  def caution_flag
    false
  end

  # method is to support frontend until has been switched over to using caution_flags attribute
  def caution_flag_reason
    ''
  end
end
