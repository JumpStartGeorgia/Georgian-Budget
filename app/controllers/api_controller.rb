class ApiController < ApplicationController
  def main
    parameters = api_params
    version = parameters[:version]

    if version == 'v1'
      response = API::V1::Response.new(parameters)
      status = 200
    else
      response = {
        errors: [{
          text: "API version \"#{version}\" does not exist"
        }]
      }
      status = 400
    end

    render json: SnakeCamelCase.to_camel_case_sym(response.to_hash),
           status: status
  end

  private

  def api_params
    snake_case_params.permit(
      :version,
      :locale,
      :budget_item_fields,
      :filters,
      budget_item_ids: [],
      filters: [
        :finance_type,
        :budget_item_type,
        :time_period_type
      ]
    )
  end

  def snake_case_params
    new_params = params.to_unsafe_h.deep_transform_keys!(&:underscore)

    if new_params[:filters].present? && new_params[:filters].is_a?(String)
      new_params[:filters] = JSON.parse(params[:filters].to_s).deep_transform_keys!(&:underscore)
    end

    ActionController::Parameters.new(new_params)
  end
end
