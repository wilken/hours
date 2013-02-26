var hoursApp = angular.module('hoursApp',[])

hoursApp.config(function($routeProvider){
	$routeProvider
	.when('/hours',{
		templateUrl: 'partials/hours.html',
		controller: 'hoursCtrl'
	})
	.when('/hours/:date',{
		templateUrl: 'partials/hours.html',
		controller: 'hoursCtrl'
	})
	.when('/summary',{
		templateUrl: 'partials/summary.html',
		controller: 'summaryCtrl'
	})
	.when('/summary/:month',{
		templateUrl: 'partials/summary.html',
		controller: 'summaryCtrl'
	})
	.otherwise({redirectTo: '/hours'})
})

hoursApp.run(function($rootScope, $http) {
	$rootScope.companies = ['KMD','BEC','TopDanmark']
	$rootScope.descriptions = ['cool','great','radical']
	console.log('data set')
})

hoursApp.directive('hrPositiveDecimal', function($parse) {
	return {
		restrict:'A',
		require: 'ngModel',
		link:function (scope, element, attrs) {
	        scope.$watch(attrs.ngModel, function (value, oldValue) {

	        	//Only allow positive decimals
	        	if(value-0 != value || value -0 <0) {

	        		//Otherwisw keep the old value
	        		$parse(attrs.ngModel).assign(scope, oldValue)
	        	}
			})
	    }
	}
})


hoursApp.directive('hrTypeahead', function($parse) {
	return {
		restrict:'A',
		link:function (scope, element, attrs) {
			var fn=$parse(attrs.hrTypeahead)
			element.typeahead({source: fn(scope)})

			element.change(function(){
	        	$parse(attrs.ngModel).assign(scope, element.val())
	        })
	    }
	}
})

hoursApp.directive('hrDatepicker', function($parse, $location) {
	return {
		restrict:'A',
		link:function (scope, element, attrs) {
			element.datepicker()
			.on('changeDate', function(event){
				element.datepicker('hide')
				$location.path('/hours/' + moment(event.date).format("YYYY-MM-DD"))
				scope.$apply()
			})
		}
	}
})


hoursApp.controller('summaryCtrl', function($scope, $routeParams){
	var month = typeof $routeParams.month == 'undefined'  ? new moment() : moment($routeParams.month,"YYYY-MM")
	$scope.month = month.format("MMMM, YYYY")
	$scope.nextMonth = month.add('months', 1).format("YYYY-MM")
	$scope.previousMonth = month.subtract('months', 2).format("YYYY-MM")
})

hoursApp.controller('hoursCtrl', function($scope, $routeParams,$location, $http	){
	var date = typeof $routeParams.date == 'undefined'  ? new moment() : moment($routeParams.date,"YYYY-MM-DD")

	$scope.ajaxDate = date.format("YYYY-MM-DD")
	$scope.date = date.format("dddd [the] Do [of] MMMM, YYYY")
	$scope.nextDate = date.add('days', 1).format("YYYY-MM-DD")
	$scope.previousDate = date.subtract('days', 2).format("YYYY-MM-DD")
	
	$scope.entries = [{"company":"","date":$scope.ajaxDate,"description":"","hours":""}]
	$http.get('entries/' + $scope.ajaxDate).success(function(data) {
		console.log(data.entries.length )
		console.log(data.entries)
  		$scope.entries = data.entries.length!=0 ? data.entries : [{"company":"","date":$scope.ajaxDate,"description":"","hours":""}];
	});

	$scope.addItem = function() {
		$scope.entries.push({"company":"","date":$scope.ajaxDate,"description":"","hours":""})
	}
	$scope.removeItem = function($index) {
		$scope.entries.splice($index,1)
		if($scope.entries.length==0) {
			$scope.entries = [{"company":"","date":$scope.ajaxDate,"description":"","hours":""}]
		}
	}
	$scope.delete = function(){	
		$scope.entries = []
		this.save()
	}
	$scope.save = function() {
		var save=[]
		for(var i=0;i<$scope.entries.length;i++){
		console.log($scope.entries[i])
			if($scope.entries[i].company!=""||$scope.entries[i].description!=""||$scope.entries[i].hours!=""){
				save.push($scope.entries[i])
			}
		}
		$http({
    		url: "entries/" + $scope.ajaxDate,
		    dataType: "json",
    		method: "POST",
    		data: '{"entries" :'+JSON.stringify($scope.entries,function(key,value){
				if(key=='$$hashKey') return undefined
				return value
			})+'}',
		    headers: {
  		      	"Content-Type": "application/json; charset=utf-8"
    		}
		}).success(function(response){
			console.log(response)
 		}).error(function(error){
 			console.log(error)
 		});

		if(save.length == 0) {
			$scope.entries = [{}]
		}else {
			$scope.entries = save
			console.log($scope.entries)
		}
	}
	$scope.getCompanies = function() {
		return $scope.companies
	}
	$scope.getDescriptions = function() {
		return $scope.descriptions
	}
})

