#!/bin/sh -ex

npm install
./node_modules/bower/bin/bower install
rm -rf public/lib/
mkdir public/lib/
ln -s ../../bower_components/angular/ public/lib/angular
ln -s ../../bower_components/bootstrap/ public/lib/bootstrap
ln -s ../../bower_components/jquery/ public/lib/jquery
