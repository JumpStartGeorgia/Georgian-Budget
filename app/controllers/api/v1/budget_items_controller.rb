module Api
  module V1
    class BudgetItemsController < ApplicationController
      def show
        budget_item = BudgetItem.find_by_perma_id(api_params[:id])

        if budget_item.present?
          budget_item_object = API::V1::BudgetItemHash.new(
            budget_item,
            fields: API::V1::BudgetItemFields.validate(api_params[:budget_item_fields]),
            time_period_type: api_params['time_period_type']
          ).to_hash

          render json: { errors: [], budget_item: budget_item_object },
                 status: 200
        end
      end

      def main
        response = API::V1::Response.new(api_params)
        status = 200

        render json: response.to_hash,
               status: status
      end

      private

      def api_params
        snake_case_params.permit(
          :id,
          :version,
          :locale,
          :budget_item_fields,
          :filters,
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
