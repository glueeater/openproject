module API
  module V3
    module Categories
      class CategoriesAPI < Grape::API

        resources :categories do
          before do
            @categories = @project.categories
            models = @categories.map { |category| ::API::V3::Categories::CategoryModel.new(category) }
            @represented = ::API::V3::Categories::CategoryCollectionRepresenter.new(models, project: @project)
          end

          get do
            @represented.to_json
          end
        end

      end
    end
  end
end
