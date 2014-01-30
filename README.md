Super easy way to que up processes needing resources, or balls.

You hold a ball and put it back when you're done. If you're waiting for a ball, no one can take it.

```
# How to use
GET /[user]/hold/[ball]
GET /[user]/put/[ball]
GET /[user]/wait_for/[ball]

# See all balls:
GET /balls

# Example
GET /dude/hold/ball
GET /bro/hold/ball # 405 status code
GET /dude/put/ball
GET /bro/hold/ball

```

Todo:
=====
- Request key
- Timeout for next up

