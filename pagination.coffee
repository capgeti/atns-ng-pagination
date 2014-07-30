module = angular.module 'atns.ng.pagination', ['ngRoute']

module.factory 'pagination', ($location, $routeParams)->
    setPage: (paramName, callback)->
        (page)->
            $location.search paramName, page
            $routeParams[paramName] = page
            callback?()

    loadPage: (currentScope, service, queryParams, callback)->
        currentScope.pageSize = parseInt(currentScope.pageSize) or 20
        currentScope.currentPage = parseInt(currentScope.currentPage) or 1
        params =
            start: currentScope.pageSize * (currentScope.currentPage - 1)
            size: currentScope.pageSize

        params[key] = queryParams[key] for key of queryParams when queryParams[key]?

        service params, (result, headers)->
            currentScope.totalPages = Math.ceil(headers('total') / currentScope.pageSize) or 1
            callback?(result, headers)


module.controller 'PaginationCtrl', ($scope)->
    $scope.$parent.$watch 'currentPage * totalPages', ->
        c = $scope.$parent.currentPage
        t = $scope.$parent.totalPages
        p = $scope.p = [1]
        p.push t  if not p.contains(t)
        p.push c  if not p.contains(c)
        p.push c - 1  if p.length < 5 and c - 1 > 1 and not p.contains(c - 1)
        p.push c + 1  if p.length < 5 and c + 1 < t and not p.contains(c + 1)
        p.push c - 2  if p.length < 5 and c - 2 > 1 and not p.contains(c - 2)
        p.push c + 2  if p.length < 5 and c + 2 < t and not p.contains(c + 2)
        p.sort (a, b)->
            a - b

        p.splice 1, 0, 2  if p[1] is 3
        p.splice 1, 0, '..'  if p.length > 1 and p[1] isnt `undefined` and p[1] isnt 2
        if p.length > 3
            p.splice p.length - 1, 0, t - 1  if p[p.length - 2] is t - 2
            p.splice p.length - 1, 0, '..'  if p.length > 2 and p[p.length - 2] isnt t - 1
        $scope.getClass = (page)->
            if page is '..' then 'disabled ' else ((if c is page then 'active' else ''))

    $scope.page = (page)->
        $scope.$parent.page page unless page is '..'
        false