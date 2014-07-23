#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'
require 'rack/test'

describe 'API v3 available_status on work package resource' do
  include Rack::Test::Methods

  let(:authorized_user) do
    FactoryGirl.create(:user, member_in_project: project,
                              member_through_role: authorized_role)
  end

  let(:unauthorized_user) do
    FactoryGirl.create(:user, member_in_project: project,
                              member_through_role: unauthorized_role)
  end
  let(:authorized_role) { FactoryGirl.create(:role, permissions: [:edit_work_packages]) }
  let(:unauthorized_role) { FactoryGirl.create(:role, permissions: []) }
  let(:project) { FactoryGirl.create(:project, is_public: false) }
  let(:work_package) do
    FactoryGirl.build_stubbed(:work_package, project: project)
  end
  let(:status) do
    FactoryGirl.build_stubbed(:status)
  end

  describe '#get work_packages/:id/available_statuses' do
    let(:get_path) { "/api/v3/work_packages/#{work_package.id}/available_statuses" }
    subject(:response) { last_response }

    def status_to_json_collection(status)
      model = Array(status).map { |s| ::API::V3::Statuses::StatusModel.new(s) }
      ::API::V3::WorkPackages::AvailableStatusCollectionRepresenter.new(model).to_json(work_package_id: work_package.id)
    end

    context 'permitted user' do
      let(:new_type_id) { '1' }
      before do
        allow(User).to receive(:current).and_return authorized_user

        expect(WorkPackage).to receive(:find).with(work_package.id.to_s)
                                             .and_return(work_package)
        expect(work_package).to receive(:new_statuses_allowed_to).with(authorized_user)
                                                                 .and_return([status])

        expect(work_package).to receive(:type_id=).with(new_type_id)

        get get_path, type: new_type_id
      end

      it 'should respond with 200' do
        expect(subject.status).to eql(200)
      end

      it 'should return a json collection of all statuses' do
        expect(response.body).to eql(status_to_json_collection(status))
      end
    end

    context 'unauthorized user' do
      before do
        allow(User).to receive(:current).and_return unauthorized_user

        allow(WorkPackage).to receive(:find).with(work_package.id.to_s)
                                            .and_return(work_package)

        get get_path
      end

      it 'should respond with 403' do
        expect(subject.status).to eql(403)
      end
    end
  end
end
