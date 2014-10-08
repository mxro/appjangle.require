<!-- one.download http://slicnet.com/mxrogm/mxrogm/data/stream/2014/1/24/n3 -->window.Appjangle = window.Appjangle or {}


window.Appjangle.install = (id, script, contextVariables, callback) ->
  if (not contextVariables) and window.Appjangle.priv.scriptCache[id]
    cached = window.Appjangle.priv.scriptCache[id]
    if cached == window.Appjangle.priv.undefinedResult
      callback(null, undefined)
      return
    
    callback(null, cached)
    return
  
 
  sourceUrl = "//@ sourceURL="+id+".value.js\n"
  
  # Defining variables available in script
  vars = ""
  if contextVariables
    for k, v in contextVariables
      vars += 'var '+k+' = contextVariables['+k+'];'
  console.log 'eval '+sourceUrl
  console.log script
  try
    lib = eval(sourceUrl+vars+script)
  catch e
    callback {
      exception : e,
      jsException: e,
      stacktrace : e.stack,
      origin : "Evaluating '"+sourceUrl+"'"
    }
    return
    
  if typeof lib != 'function'
    libsafe = lib or window.Appjangle.priv.undefinedResult
    window.Appjangle.priv.scriptCache[id] = libsafe
    callback(null, lib)
    return
  
  lib (ex, lib) ->
    if (ex)
      callback(ex)
      return
    
    window.Appjangle.priv.scriptCache[id] = lib
    callback(null, lib)
    return

window.Appjangle.uninstall = (id) ->
  delete window.Appjangle.priv.scriptCache[id]
  
window.Appjangle.priv = window.Appjangle.priv or {}

window.Appjangle.priv.scriptCache = window.Appjangle.priv.scriptCache or {}

window.Appjangle.priv.undefinedResult = {}

window.Appjangle<!-- one.end -->
