//-- copyright
// OpenProject is a project management system.
// Copyright (C) 2012-2014 the OpenProject Foundation (OPF)
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See doc/COPYRIGHT.rdoc for more details.
//++

angular.module('openproject.workPackages.helpers')

.constant('PERMITTED_CONTEXT_MENU_ACTIONS', ['edit', 'watch', 'log_time', 'duplicate', 'move', 'copy', 'delete'])
.constant('PERMITTED_BULK_ACTIONS',         ['edit', 'watch', 'move', 'copy', 'delete'])

.service('WorkPackageContextMenuHelper', ['PERMITTED_CONTEXT_MENU_ACTIONS', 'PERMITTED_BULK_ACTIONS', 'WorkPackagesTableService', 'UrlParamsHelper', function(PERMITTED_CONTEXT_MENU_ACTIONS, PERMITTED_BULK_ACTIONS, WorkPackagesTableService, UrlParamsHelper) {
  function getPermittedActionLinks(workPackage) {
    var linksToPermittedActions = {};
    var permittedActions = getIntersection([workPackage._actions, PERMITTED_CONTEXT_MENU_ACTIONS]);

    angular.forEach(permittedActions, function(permittedAction) {
      linksToPermittedActions[permittedAction] = workPackage._links[permittedAction];
    });

    return linksToPermittedActions;
  }

  function getIntersectOfPermittedActions(workPackages) {
    var linksToPermittedActions = {};
    var permittedActions = getIntersection(
      workPackages
        .map(function(workPackage) {
          return workPackage._actions;
        })
        .concat(new Array(PERMITTED_BULK_ACTIONS))
    );

    angular.forEach(permittedActions, function(permittedAction) {
      linksToPermittedActions[permittedAction] = getBulkActionLink(permittedAction, workPackages);
    });

    return linksToPermittedActions;
  }

  function getBulkActionLink(action, workPackages) {
    var bulkLinks = WorkPackagesTableService.getBulkLinks();

    var workPackageIdParams = {
      'ids[]': workPackages.map(function(wp){
        return wp.id;
      })
    };
    var serializedIdParams = UrlParamsHelper.buildQueryString(workPackageIdParams);

    var linkAndQueryString = bulkLinks[action].split('?');
    var link = linkAndQueryString.shift();
    var queryParts = linkAndQueryString.concat(new Array(serializedIdParams));

    return link + '?' + queryParts.join('&');
  }

  // TODO move to a global tools helper
  function getIntersection(arrays) {
    var candidates = arrays.shift();

    return candidates.filter(function(element) {
      return arrays.every(function(array) {
        return array.indexOf(element) !== -1;
      });
    });
  }

  var WorkPackageContextMenuHelper = {
    getPermittedActions: function(workPackages) {
      if (workPackages.length === 1) {
        return getPermittedActionLinks(workPackages[0]);
      } else if (workPackages.length > 1) {
        return getIntersectOfPermittedActions(workPackages);
      }
    }
  };

  return WorkPackageContextMenuHelper;
}]);
