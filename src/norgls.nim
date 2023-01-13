import json
import std/[asyncdispatch, asyncfile, streams, uri]
import asynctools/asyncproc

include lsp/messages

type
  LogLevel {.pure.} = enum
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
    debug.log("Unable to parse data as ", kind)

proc main(ins: Stream | AsyncFile, outs: Stream | AsyncFile) {.async.}=
  while true:
    try:
      let frame = await ins.readLine
      let message = frame.parseJson
      whenValid(message, RequestMessage):
        echo("recieved valid LSP request")
    except UriParseError as e:
      LogLevel.warn.log("Got exception parsing URI: ", e.msg)
      continue
    except IOError as e:
      LogLevel.error.log("Got IOError: ", e.msg)
      break
    except CatchableError as e:
      LogLevel.warn.log("Got exception: ", e.msg)
      continue

var
  ins = newAsyncFile(stdin.getOsFileHandle().AsyncFD)
  outs = newAsyncFile(stdout.getOsFileHandle().AsyncFD)
waitFor main(ins, outs)
