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

describe WorkPackages::ReportsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:project) { FactoryGirl.create(:project) }
  let(:role) { FactoryGirl.create(:role,
                                  permissions: [:view_work_packages]) }
  let(:member) { FactoryGirl.create(:member,
                                    project: project,
                                    principal: user,
                                    roles: [role]) }
  let(:work_package_1) { FactoryGirl.create(:work_package,
                                            id: 21,
                                            subject: "Can't print recipes",
                                            project: project) }
  let(:work_package_2) { FactoryGirl.create(:work_package,
                                            id: 2101,
                                            subject: "Error 281 when updating a recipe",
                                            project: project) }
  let(:work_package_3) { FactoryGirl.create(:work_package,
                                            id: 2102,
                                            project: project) }

  before do
    member

    allow(User).to receive(:current).and_return user

    work_package_1
    work_package_2
    work_package_3
  end

  describe :report do
    describe "w/o details" do
      before { get :report, project_id: project.id }

      subject { response }

      it { should be_success }

      it { should render_template('report') }

      it { assigns :work_packages_by_type }

      it { assigns :work_packages_by_version }

      it { assigns :work_packages_by_category }

      it { assigns :work_packages_by_assigned_to }

      it { assigns :work_packages_by_responsible }

      it { assigns :work_packages_by_author }

      it { assigns :work_packages_by_subproject }
    end

    describe "with details" do
      shared_examples_for "details view" do
        before { get :report_details, project_id: project.id, detail: detail }

        subject { response }

        it { should be_success }

        it { should render_template('report_details') }

        it { assigns :field }

        it { assigns :rows }

        it { assigns :data }

        it { assigns :report_title }
      end

      describe :type do
        let(:detail) { 'type' }

        it_behaves_like "details view"
      end

      describe :version do
        let(:detail) { 'version' }

        it_behaves_like "details view"
      end

      describe :priority do
        let(:detail) { 'priority' }

        it_behaves_like "details view"
      end

      describe :category do
        let(:detail) { 'category' }

        it_behaves_like "details view"
      end

      describe :assigned_to do
        let(:detail) { 'assigned_to' }

        it_behaves_like "details view"
      end

      describe :responsible do
        let(:detail) { 'responsible' }

        it_behaves_like "details view"
      end

      describe :author do
        let(:detail) { 'author' }

        it_behaves_like "details view"
      end

      describe :subproject do
        let(:detail) { 'subproject' }

        it_behaves_like "details view"
      end

      context "invalid detail" do
        before { get :report_details, project_id: project.id, detail: 'invalid' }

        subject { response }

        it { should be_redirect }

        it { should redirect_to(report_project_work_packages_path(project.identifier)) }
      end
    end
  end
end
