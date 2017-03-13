module Api
  module V1
    class PageContentsController < ApplicationController
      def show
        @page_content = PageContent.find_by_name(page_contents_params['id'])

        return unless @page_content.present?

        render json: @page_content,
               status: 200
      end

      private

      def page_contents_params
        params.permit(
          :locale,
          :id
        )
      end
    end
  end
end
