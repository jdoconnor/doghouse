#### Routes
# We are setting up these routes:
#
# GET, POST, PUT, DELETE methods are going to the same controller methods - we don't care.
# We are using method names to determine controller actions for clearness.

module.exports  = (app) ->
  # - _/_ -> controllers/index/index method
  app.all '/', (req, res, next) ->
    routeMvc('index', 'index', req, res, next)

  # - _/**:controller**_  -> controllers/***:controller***/index method
  app.all '/:controller', (req, res, next) ->
    routeMvc(req.params.controller, 'index', req, res, next)
  
  # - _/**:controller**/**:method**_ -> controllers/***:controller***/***:method*** method
  app.all '/:controller/:method', (req, res, next) ->
    routeMvc(req.params.controller, req.params.method, req, res, next)

  # - _/**:controller**/**:method**/**:id**_ -> controllers/***:controller***/***:method*** method with ***:id*** param passed
  app.all '/:controller/:id/:method', (req, res, next) ->
    routeMvc(req.params.controller, req.params.method, req, res, next)

  # If all else failed, show 404 page
  app.all '/*', (req, res) ->
    console.warn "error 404: ", req.url
    res.render '404', 404

# render the page based on controller name, method and id
routeMvc = (controllerName, methodName, req, res, next) =>
  # this is a very dynamic application, and we don't want any caching
  res.header("Cache-Control", "no-cache, no-store, must-revalidate");
  res.header("Pragma", "no-cache");
  res.header("Expires", 0);
  # route onto a controller mathod
  controllerName = 'index' if not controllerName?
  controller = null
  try
    controller = require "./controllers/" + controllerName
  catch e
    console.warn "controller not found: "+ controllerName, e
    next()
    return
  data = null
  if methodName?
    # eval is evil, so sanitize it
    methodName = methodName.replace(/[^a-z0-9A-Z_-]/i, '')
    method = eval('controller.' + methodName)
    if method?
      method req, res, next
  else
    console.warn 'method not found: ' + methodName
    next()
