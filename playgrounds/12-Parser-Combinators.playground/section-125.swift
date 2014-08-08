func pExpression() -> Calculator {
  return operatorTable.reduce(number, { next, inOp in
     op(inOp.0, inOp.1, next)
  })
}
testParser(pExpression() <* eof(), "10-3*2")