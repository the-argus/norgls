include lsp/messages

proc processRequest*(message: RequestMessage): Diagnostic =
  let response = create(Diagnostic,
    create(Range,
      create(Position, 0, 0),
      create(Position, 0, 1)
    ), some(DiagnosticSeverity.Error.int), none(int), some("none"),
    "testing diagnostic",
    none(seq[DiagnosticRelatedInformation]))
  return response

