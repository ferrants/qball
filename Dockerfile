FROM node:0.10-onbuild
MAINTAINER Matt Ferrante "mferrante3@gmail.com"
RUN npm install -g coffee-script
RUN ./node_modules/bower/bin/bower install --allow-root
EXPOSE 8080
CMD ["coffee", "server.coffee"]
