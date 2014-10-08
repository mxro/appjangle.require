<!-- one.download http://slicnet.com/mxrogm/mxrogm/data/stream/2014/1/24/n2 -->window.Appjangle = window.Appjangle or {}

priv = {}

priv.requireOne = (node, contextVariables, callback) ->
  
  Appjangle.install node.uri(), node.value(), contextVariables, (ex, lib) ->

    callback(ex, lib)

priv.createMapFunction = (contextVariables) ->
  (node, callback) ->
    priv.requireOne node, contextVariables, callback
    
priv.require = (links, contextVariables, callback) ->
  
  queries = links.slice(0); # make copy of array
  
  # onSuccess
  queries.push ->
    async.map arguments, # nodes
              priv.createMapFunction(contextVariables),
              callback
  
  # onFailure
  queries.push (ex) ->
    callback(ex)
  
  links[0].getSession().getAll queries

priv.triggerCallback = (args, ex, libs, callback) ->
  if $.isArray(args[0])
    callback(ex, libs)
    return
  
  callback.apply this, [ex].concat(libs)


priv.parseArguments = (args) ->
  links = []
  uris = []
  callback = null
  contextVariables = null
  session = null
  sessionCloseRequired = false
  
  for argument in args
    if argument == null
      continue
    
    # first argument is array
    if argument.length and $.isArray(argument)
      links = argument
      continue
    
    # starting arguments are links
    if argument.uri && typeof argument.uri == 'function'
      links.push argument
      continue
    
    # or strings
    if typeof argument == 'string'
      uris.push argument
      continue
    
    if typeof argument == 'function'
      callback = argument
      continue

    # is an map with context variables
    contextVariables = argument
  
  if links.length > 0
    session = links[0].getSession()
  else
    session = AppjangleJs.createSessionWithCache()
    sessionCloseRequired = true
  
  for uri in uris
    links.push session.link(uri)
  
  return {
    links: links
    uris: uris
    callback: callback
    contextVariables: contextVariables
    session: session
    sessionCloseRequired: sessionCloseRequired
  }
  
window.Appjangle.require = ->
  args = priv.parseArguments arguments
    
  if not args.callback
    throw new Error('Define a callback function
                    as last paramter for Appjangle.require')
  
  
  
  if args.links.length == 0
    args.callback(null, [])
    return
  
  arguments_closed = arguments
  priv.require args.links, args.contextVariables, (ex, libs) ->
    priv.triggerCallback arguments_closed, ex, libs, args.callback
    
    #console.log 'close required '+args.sessionCloseRequired
    if args.sessionCloseRequired
      args.session.close().get(->)
 

window.Appjangle.requireNew = ->
  
  arguments_closed = arguments
  args = priv.parseArguments arguments
  
  ops = []
  if args.links.length > 0
    for link in args.links
      Appjangle.uninstall link.uri()
      ops.push link.reload()
  ((arguments_closed) ->
    ops.push ->
      
      window.Appjangle.require.apply this, arguments_closed
       
      if args.sessionCloseRequired
        args.session.close().get(->)
  )(arguments_closed)
  
  ops.push (ex) ->
    args.callback ex
  
  
  args.session.getAll ops
  
window.Appjangle<!-- one.end -->
