FROM node:0.10-onbuild
MAINTAINER Matt Ferrante "mferrante@dataxu.com"
RUN npm install -g coffee-script
EXPOSE 8080
CMD ["coffee", "server.coffee"]
