Super easy way to queue up processes needing locks on resources, or balls in this metaphore

You hold a ball and put it back when you're done. If you're waiting for a ball, no one else can take it.

Web API:
========
```
# How to use
GET /[user]/hold/[ball]     # take the ball
GET /[user]/put/[ball]      # return the ball
GET /[user]/wait_for/[ball] # wait in line for ball

# Admin
GET /balls                  # show all balls
GET /balls/[ball]           # show ball info
GET /balls/[ball]/kick      # kick holder of ball
GET /balls/[ball]/rotate    # move person first in ball's queue to the end
GET /balls/[ball]/clear     # clear ball's queue and holder
GET /balls/[ball]/drop      # destroy the ball


# Sample Flow
GET /dude/hold/ball
GET /bro/hold/ball          # 405 Status Code
GET /bro/wait_for/ball
GET /dude/put/ball
GET /bro/hold/ball
```

See test/test.coffee for examples

Integrations
============
- Python: qball-python (https://github.com/ferrants/qball-python)

Todo:
=====
- If compliance to the line isn't working, hide the list and allow people to request keys which they can use
- Timeout for person who is next up
- Intentionally made all the requests a GET for simplicity. This may change this at some point
- Ready url to post to
