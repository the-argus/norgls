import std/[asyncdispatch, asyncfile, streams, strutils]
import asynctools/asyncproc

proc main(ins: Stream | AsyncFile, outs: Stream | AsyncFile) {.multisync.} =
    echo("hello")

when defined(windows):
  var
    ins = newFileStream(stdin)
    outs = newFileStream(stdout)
  main(ins, outs)
else:
  var
    ins = newAsyncFile(stdin.getOsFileHandle().AsyncFD)
    outs = newAsyncFile(stdout.getOsFileHandle().AsyncFD)
  waitFor main(ins, outs)
