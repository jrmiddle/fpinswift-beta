func pExpression2() -> Calculator {
    return operatorTable.reduce(number, { (next: Calculator, op: Op) in
        operator1(op.0, op.1, next)
    })
}
testParser(pExpression2(), "1+3*3")