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

  $scope.drop_ball = function(ball_name){
    console.log(ball_name);
    $http.get('/balls/' + ball_name + '/drop').success(function(data) {
      $scope.refresh_balls()
    });
  };
  $scope.clear_ball = function(ball_name){
    console.log(ball_name);
    $http.get('/balls/' + ball_name + '/clear').success(function(data) {
      $scope.refresh_balls()
    });
  };
});
