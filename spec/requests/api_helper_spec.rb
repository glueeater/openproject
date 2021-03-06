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

shared_examples_for "safeguarded API" do
  it { expect(response.response_code).to eq(403) }
end

shared_examples_for "valid activity request" do
  let(:status_code) { 200 }

  before { allow(User).to receive(:current).and_return(admin) }

  it { expect(response.response_code).to eq(status_code) }

  describe 'response body' do
    subject { JSON.parse(response.body) }

    it { expect(subject['_type']).to eq("Activity::Comment") }

    it { expect(subject['rawComment']).to eq(comment) }
  end
end

shared_examples_for "invalid activity request" do
  before { allow(User).to receive(:current).and_return(admin) }

  it { expect(response.response_code).to eq(422) }
end
