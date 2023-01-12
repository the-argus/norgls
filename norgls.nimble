# Package

version       = "0.0.1"
author        = "the-argus"
description   = "N LSP implementation for neorgs .norg markdown-like filetype"
license       = "GPL v3"
srcDir        = "src"
bin           = @["norgls"]

# Dependencies

requires "nim >= 1.0.0"
requires "jsonschema >= 0.2.1"
requires "asynctools >= 0.1.1"
