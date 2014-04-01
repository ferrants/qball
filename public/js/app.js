var qball = angular.module('qball', []);

qball.filter('fromNow', function() {
  return function(date) {
    return moment(date).fromNow();
  }
});

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
    $scope.hit('balls', ball_name, action);
  };

  $scope.hit = function(p1, p2, p3){
    var url = '/' + [p1, p2, p3].join('/');
    console.log(url)
    $http.get(url).success(function(data) {
      $scope.refresh_balls()
    });
  };

});
