class V1::Lcpe::LacsController < ApplicationController

  rescue_from StandardError do |exception|
    Rails.logger.error(exception.full_message)
    render json: { error: exception.message }, status: :internal_server_error
  end
  
  def index
    results = Lcpe::Lac.all

    json = 
      results
        .map do |r|
          {
            id: "#{r.id}@#{r.facility_code}",
            name: r.lac_nm,
            type: r.edu_lac_type_nm
          }
        end
        .to_json

    render(json:)
  end

  def show
    json =
      Lcpe::Lac
        .where(show_params)
        .includes([:lac_tests, :institution])
        .first
        .to_json(
          include: [
            :lac_tests, 
            institution: {
              only: 
                [].tap do |a|
                  fields = %w(address_1 address_2 address_3 city state zip country)
                  a.replace(fields + fields.map { |f| "physical_#{f}" })
                end
            }
          ]
        )

    render(json:)
  end

  def show_params
    # Match the first part containing only digits followed by an @
    match = params.require(:id).match(/\A(\d+)@(.+)\z/)

    raise ActionController::BadRequest, "Invalid ID format" unless match

    {
      id: match[1], 
      facility_code: match[2]
    }
  end
end
