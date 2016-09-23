class ApiController < ApplicationController
  def main
    version = params['version']
    if version == 'v1'
      response = APIResponse.new(params)

      render json: response.to_json,
             status: :ok
    else
      response = {
        error: "API version \"#{version}\" does not exist"
      }
      render json: response.to_json,
             status: :ok
    end
  end
end
