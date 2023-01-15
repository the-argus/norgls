import json
import os
import std/[asyncdispatch, asyncfile, streams, uri]
import asynctools/asyncproc

# unfortunately jsonschema objects as defined in lsp/messages are private, so
# we have to use include and make this whole module one big file
include lsp_implementation

# milliseconds between iterations of the main while loop.
const RESPONSE_MS = 100

type
  LogLevel = enum
    debug, warn, error

proc log(level: LogLevel, args: varargs[string, `$`]) =
  if level == LogLevel.debug:
    for arg in args:
      echo(arg)
  elif level == LogLevel.warn:
    for arg in args:
      echo(arg)
  elif level == LogLevel.error:
    for arg in args:
      echo(arg)

template whenValid(data, kind, body) =
  if data.isValid(kind):
    var data = kind(data)
    body
  else:
    log(LogLevel.debug, "Unable to parse data as ", kind)

proc main(ins: Stream | AsyncFile, outs: Stream | AsyncFile) {.async.}=
  while true:
    try:
      # read stdin asynchronously
      let frame = await ins.readAll()
      if frame == "":
        os.sleep(RESPONSE_MS)
        continue
      
      # parse as json
      let message = frame.parseJson()
      whenValid(message, RequestMessage):
        echo("recieved valid LSP request")
        await outs.write(`$` JsonNode(processRequest(message)))
    except UriParseError as e:
      log(LogLevel.warn, "Got exception parsing URI: ", e.msg)
      continue
    except IOError as e:
      log(LogLevel.error, "Got IOError: ", e.msg)
      break
    except CatchableError as e:
      log(LogLevel.warn, "Got exception: ", e.msg)
      continue

var
  ins = newAsyncFile(stdin.getOsFileHandle().AsyncFD)
  outs = newAsyncFile(stdout.getOsFileHandle().AsyncFD)
waitFor main(ins, outs)
