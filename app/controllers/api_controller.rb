class ApiController < ApplicationController
  def main
    version = api_params[:version]

    if version == 'v1'
      response = APIResponse.new(api_params)
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
      :budget_item_ids,
      :finance_type,
      :filters,
      filters: [:budget_item_type]
    )
  end

  def snake_case_params
    params.transform_keys!(&:underscore)
    params[:filters].transform_keys!(&:underscore) if params[:filters]
    params
  end
end
