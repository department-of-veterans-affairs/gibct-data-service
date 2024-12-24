class V1::Lcpe::ExamsController < ApplicationController
  def index
    results = Lcpe::Exam.all

    json = 
      results
        .map do |r|
          {
            id: "#{r.id}@#{r.facility_code}",
            name: r.nexam_nm
          }
        end
        .then do |t|
          t.to_json
        end

    render(json:)
  end

  def show
  end
end
