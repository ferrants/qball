Super easy way to queue up processes needing locks on resources, or balls in this metaphore

You hold a ball and put it back when you're done. If you're waiting for a ball, no one else can take it.

Web API:
========
```
# How to use
GET /[user]/hold/[ball]
GET /[user]/put/[ball]
GET /[user]/wait_for/[ball]

# Info
GET /balls
GET /balls/[ball]

# Sample Flow
GET /dude/hold/ball
GET /bro/hold/ball # 405 Status Code
GET /bro/wait_for/ball
GET /dude/put/ball
GET /bro/hold/ball

```

See test/test.coffee for examples


Todo:
=====
- Request key
- Timeout for next up
