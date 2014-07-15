require 'spec_helper'
require 'rack/test'

describe 'API v3 Category resource' do
  include Rack::Test::Methods

  let(:current_user) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role, permissions: []) }
  let(:project) { FactoryGirl.create(:project, is_public: false) }
  let(:categories) { FactoryGirl.create_list(:category, 3, project: project) }
  let(:other_categories) { FactoryGirl.create_list(:category, 2) }

  describe '#get' do
    subject(:response) { last_response }

    context 'logged in user' do
      let(:get_path) { "/api/v3/projects/#{project.id}/categories" }
      before do
        allow(User).to receive(:current).and_return current_user
        member = FactoryGirl.build(:member, user: current_user, project: project)
        member.role_ids = [role.id]
        member.save!

        categories
        other_categories

        get get_path
      end

      it 'should respond with 200' do
        expect(subject.status).to eq(200)
      end

      it 'should respond with categories' do
        expect(subject.body).to include_json('Categories'.to_json).at_path('_type')
        expect(subject.body).to have_json_size(3).at_path('_embedded/categories')
      end
    end
  end
end
