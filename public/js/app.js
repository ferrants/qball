var qball = angular.module('qball', []);

qball.controller('QBallControl', function($scope, $http){
  $scope.data = {'balls': {}};

  $scope.balls = function(){
    return $scope.data.balls;
  };

  $scope.refresh_balls = function(){
    $http.get('/balls').success(function(data) {
      console.log(data);
      $scope.data.balls = data;
    });
  };

  $scope.use_ball = function(action, ball_name){
    console.log(ball_name);
    $http.get('/balls/' + ball_name + '/' + action).success(function(data) {
      $scope.refresh_balls()
    });
  };

});
