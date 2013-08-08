fs   = require 'fs'
util = require "util"
log = fs.createWriteStream(process.cwd() + "/test/stdout.log")
console.log = console.info = (t) ->
  out = undefined
  if t and ~t.indexOf("%")
    out = util.format.apply(util, arguments)
    process.stdout.write out + "\n"
    return
  else
    out = Array::join.call(arguments, " ")
  out and log.write(out + "\n")

console.log 'test'