module API
  module V3
    module Relations
      class RelationsAPI < Grape::API

        resources :relations do
          params do
            optional :to_id, desc: 'Id of related work package'
            optional :relation_type, desc: 'Type of relationship'
            optional :delay
          end
          post do
            authorize(:manage_work_package_relations, context: @work_package.project)
            declared_params = declared(params).reject{ |key, value| key.to_sym == :id || value.nil? }

            relation = @work_package.new_relation.tap do |r|
              r.to = WorkPackage.visible.find_by_id(declared_params[:to_id].match(/\d+/).to_s)
              r.relation_type = declared_params[:relation_type]
              r.delay = declared_params[:delay_id]
            end

            if relation.valid? && relation.save
              model = ::API::V3::WorkPackages::RelationModel.new(relation)
              representer = ::API::V3::WorkPackages::RelationRepresenter.new(model)
              representer.to_json
            else
              raise ::API::Errors::Validation.new(relation)
            end
          end

          namespace ':id' do
            delete do
              authorize(:manage_work_package_relations, context: @work_package.project)
              relation = Relation.find(params[:id])
              relation.delete
              status 204
            end
          end
        end

      end
    end
  end
end
