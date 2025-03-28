# frozen_string_literal: true

class V1::Lcpe::ExamsController < V1::LcpeBaseController
  before_action :validate_preload_version, only: :show

  def index
    results = preload_dataset || Lcpe::Exam.with_enriched_id

    render json: results, each_serializer: Lcpe::ExamSerializer, adapter: :json, action: 'index'
  end

  def show
    result =
      Lcpe::Exam
      .by_enriched_id(params[:id])
      .includes(%i[tests institution])
      .first

    render json: result, serializer: Lcpe::ExamSerializer, adapter: :json, action: 'show'
  end
end
