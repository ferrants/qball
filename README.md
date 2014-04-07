Super easy way to queue up processes needing locks on resources, or balls in this metaphore

You hold a ball and put it back when you're done. If you're waiting for a ball, no one else can take it. 

Running:
========
```
# Set up repo, bower install, npm install, linking
./init.sh

# Run on port 8080
coffee server.coffee

# Run on port 9090
HTTP_PORT=9090 coffee server.coffee
```

Admin:
======
Visit the base url, you will see an admin panel. You can enable auto-admin so you don't have to worry about it.

Web API:
========
```
# How to use
GET /[user]/hold/[ball]          # take the ball
GET /[user]/put/[ball]           # return the ball
GET /[user]/wait_for/[ball]      # wait in line for ball
GET /[user]/stop_wait_for/[ball] # stop waiting in line for ball

# Admin
GET /                            # admin UI screen
GET /balls                       # show all balls
GET /balls/[ball]                # show ball info
GET /balls/[ball]/kick           # kick holder of ball
GET /balls/[ball]/rotate         # move person first in ball's queue to the end
GET /balls/[ball]/clear          # clear ball's queue and holder
GET /balls/[ball]/drop           # destroy the ball
GET /balls/[ball]/auto_admin     # toggle automatic administration

# Sample Flow
GET /dude/hold/ball
GET /bro/hold/ball               # 405 Status Code
GET /bro/wait_for/ball
GET /dude/put/ball
GET /bro/hold/ball
```

See test/test.coffee for examples

Integrations
============
- Python: qball-python (https://github.com/ferrants/qball-python)

