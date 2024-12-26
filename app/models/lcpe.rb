# frozen_string_literal: true

module Lcpe
  extend Edm::SqlContext

  def self.table_name_prefix
    'lcpe_'
  end

  def self.reset
    pure_sql
      .join(Lcpe::Exam.reset)
      .join(Lcpe::ExamTest.reset)
      .join(Lcpe::Lac.reset)
      .join(Lcpe::LacTest.reset)
  end
end
