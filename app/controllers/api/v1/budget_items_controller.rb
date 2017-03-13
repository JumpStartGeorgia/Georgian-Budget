module Api
  module V1
    class BudgetItemsController < ApplicationController
      def main
        response = API::V1::Response.new(api_params)
        status = 200

        render json: response.to_hash,
               status: status
      end

      private

      def api_params
        snake_case_params.permit(
          :version,
          :locale,
          :budget_item_fields,
          :filters,
          :budget_item_id,
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
  end
end
