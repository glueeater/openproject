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

require 'reform'
require 'reform/form/coercion'

module API
  module V3
    module WorkPackages
      class WorkPackageModel < Reform::Form
        include Coercion
        include ActionView::Helpers::UrlHelper
        include OpenProject::TextFormatting
        include OpenProject::StaticRouting::UrlHelpers
        include WorkPackagesHelper
        include GravatarImageTag

        # N.B. required by ActionView::Helpers::UrlHelper
        def controller; nil; end

        property :subject,          type: String
        property :start_date,       type: Date
        property :due_date,         type: Date
        property :created_at,       type: DateTime
        property :updated_at,       type: DateTime
        property :author,           type: String
        property :project_id,       type: Integer
        property :responsible_id,   type: Integer
        property :assigned_to_id,   type: Integer
        property :fixed_version_id, type: Integer


        def description
          format_text(model, :description)
        end

        def raw_description
          model.description
        end

        def raw_description=(value)
          model.description = value
        end

        def type
          model.type.try(:name)
        end

        def type=(value)
          type = Type.find(:first, conditions: ['name ilike ?', value])
          model.type = type
        end

        def status
          model.status.try(:name)
        end

        def status=(value)
          status = Status.find(:first, conditions: ['name ilike ?', value])
          model.status = status
        end

        def priority
          model.priority.try(:name)
        end

        def priority=(value)
          priority = IssuePriority.find(:first, conditions: ['name ilike ?', value])
          model.priority = priority
        end

        def estimated_time
          { units: 'hours', value: model.estimated_hours }
        end

        def estimated_time=(value)
          hours = ActiveSupport::JSON.decode(value)['value']
          model.estimated_hours = hours
        end

        def version_id=(value)
          model.fixed_version_id = value
        end

        def percentage_done
          model.done_ratio
        end

        def percentage_done=(value)
          model.done_ratio = value
        end

        def author
          ::API::V3::Users::UserModel.new(model.author)  unless model.author.nil?
        end

        def responsible
          ::API::V3::Users::UserModel.new(model.responsible) unless model.responsible.nil?
        end

        def assignee
          ::API::V3::Users::UserModel.new(model.assigned_to) unless model.assigned_to.nil?
        end

        def activities
          model.journals.map{ |journal| ::API::V3::Activities::ActivityModel.new(journal) }
        end

        def attachments
          model.attachments
            .map{ |attachment| ::API::V3::Attachments::AttachmentModel.new(attachment) }
        end

        def watchers
          model.watcher_users
            .order(User::USER_FORMATS_STRUCTURE[Setting.user_format])
            .map{ |u| ::API::V3::Users::UserModel.new(u) }
        end

        validates_presence_of :subject, :project_id, :type, :author, :status
        validates_length_of :subject, maximum: 255
      end
    end
  end
end
