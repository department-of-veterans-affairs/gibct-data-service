# frozen_string_literal: true

class V1::Lcpe::LacsController < V1::LcpeBaseController
  before_action :validate_preload_version, only: :show

  def index
    render(
      {
        json: preload_dataset || list,
        each_serializer: Lcpe::LacSerializer,
        adapter: :json,
        action: 'index'
      }.tap(&method(:add_pagination_meta))
    )
  end

  def show
    result =
      Lcpe::Lac
      .by_enriched_id(params[:id])
      .includes(%i[tests institution])
      .first

    render json: result, serializer: Lcpe::LacSerializer, adapter: :json, action: 'show'
  end

  private

  def list
    return @list if defined?(@list)

    @list =
      Lcpe::Lac
      .with_enriched_id
      .where(index_params.permit(:edu_lac_type_nm, :state))
      .then do |relation|
        relation = relation.where('lac_nm ILIKE ?', "%#{index_params[:lac_nm]}%") if index_params[:lac_nm].present?
        relation = relation.paginate(page:, per_page:) if paginate?
        relation
      end
  end

  def index_params
    return @index_params if defined?(@index_params)

    @index_params = params.permit(*FILTER_PARAMS)
  end

  def page
    return @page if defined?(@page)

    @page = index_params[:page] || 1
  end

  def per_page
    return @per_page if defined?(@per_page)

    @per_page = index_params[:per_page]
  end

  def paginate_question
    return @paginate_question if defined?(@paginate_question)

    @paginate_question = index_params[:per_page].present?
  end

  alias paginate? paginate_question

  def add_pagination_meta(signature)
    paginate? ? signature.update(meta: pagination_meta) : signature
  end

  def pagination_meta
    {
      current_page: list.current_page,
      next_page: list.next_page,
      prev_page: list.previous_page, # prev_page
      total_pages: list.total_pages,
      total_count: list.total_entries # total_count
    }
  end
end
