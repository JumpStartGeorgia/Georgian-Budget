class ApiController < ApplicationController
  def main
    response = APIResponse.new(params)

    render json: response.to_json,
           status: :ok
  end
end
