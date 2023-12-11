//
//  CalculatorLogic.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 10.12.23.
//

import Foundation

public func evaluateMathExpression(_ expression: String) -> String? {
    // Step 1: Tokenize the expression
    let tokens = tokenize(expression)

    // Step 2: Parse and evaluate the expression
    let result = parseAndEvaluate(tokens)

    return result
}

private func tokenize(_ expression: String) -> [String] {
    var tokens: [String] = []
    var currentToken = ""

    for char in expression {
        if (char.isNumber || char == ".") || (char == "-" && currentToken.isEmpty) {
            currentToken.append(char)
        } else {
            if !currentToken.isEmpty && currentToken.first != "<" {
                tokens.append(currentToken)
                currentToken = ""
            }
            
            if char == "<" {
                currentToken.append(char)
            } else if char == ">" {
                currentToken.append(char)
                tokens.append(currentToken)
                currentToken = ""
            } else if !currentToken.isEmpty && currentToken.first == "<" {
                currentToken.append(char)
            } else if char != " " {
                tokens.append(String(char))
            }
        }
    }

    if !currentToken.isEmpty {
        tokens.append(currentToken)
    }

    return tokens
}

private func parseAndEvaluate(_ tokens: [String]) -> String? {
    var tks: [String] = tokens
    
    while tks.count > 1 {
        if let openingParenthesisIndex = tks.lastIndex(where: { $0 == "(" }) {
            if let closingParenthesisIndex = tks.enumerated().first(where: { $0.offset > openingParenthesisIndex && $0.element == ")" })?.offset {
                if openingParenthesisIndex + 1 > closingParenthesisIndex - 1 {
                    tks.remove(atOffsets: [openingParenthesisIndex, closingParenthesisIndex])
                } else if let expr = parseAndEvaluate(Array(tks[openingParenthesisIndex+1...closingParenthesisIndex-1])) {
                    tks.removeSubrange(openingParenthesisIndex..<closingParenthesisIndex)
                    
                    if openingParenthesisIndex > 0 && tks[openingParenthesisIndex-1] == "-" {
                        if openingParenthesisIndex > 1 && tks[openingParenthesisIndex-2] == ")" {
                            tks[openingParenthesisIndex] = expr
                        } else {
                            tks.remove(at: openingParenthesisIndex)
                            tks[openingParenthesisIndex-1] = String(-Double(expr)!)
                        }
                    } else {
                        tks[openingParenthesisIndex] = expr
                    }
                } else {
                    return nil // invalid expression within parentheses
                }
            } else {
                return nil // missing closing parenthesis ')'
            }
            
        } else if let elemFuncIndex = tks.lastIndex(where: { isElementaryFunction($0) }) {
            
            if elemFuncIndex + 1 > tks.count - 1 {
                return nil // missing parameter
            }
            
            let elemFuncResult = applyElementaryFunction(function: tks[elemFuncIndex], tks[elemFuncIndex+1])
            
            if elemFuncResult == nil {
                return nil // couldn't apply the function
            }
            
            tks.remove(at: elemFuncIndex+1)
            tks[elemFuncIndex] = elemFuncResult!
            
        } else if let op = tks.enumerated().first(where: { $0.element == "^" }) ?? tks.enumerated().first(where: { $0.element == "*" || $0.element == "/" }) ?? tks.enumerated().first(where: { isOperator($0.element) }) {
            
            if op.offset - 1 < 0 || op.offset + 1 > tks.count - 1 {
                return nil // missing operand
            }
            
            let operationResult = performOperation(tks[op.offset-1], operatorSymbol: op.element, tks[op.offset+1])
            
            if operationResult == nil {
                return nil // invalid operation
            }
            
            tks.remove(atOffsets: [op.offset, op.offset+1])
            tks[op.offset-1] = operationResult!
            
        } else {
            return nil // not enough operators
        }
    }
    
    if tks.first == nil {
        return "0" // empty expression
    }
    
    return Double(tks.first!) == nil || isOperator(tks.first!) || isElementaryFunction(tks.first!) || tks.first! == "(" || tks.first! == ")" ? nil : tks.first
}

private func isOperator(_ token: String) -> Bool {
    return token == "+" || token == "-" || token == "*" || token == "/" || token == "^"
}

private func performOperation(_ operand1: String, operatorSymbol: String, _ operand2: String) -> String? {
    if let num1 = Double(operand1), let num2 = Double(operand2) {
        switch operatorSymbol {
        case "+":
            return String(num1 + num2)
        case "-":
            return String(num1 - num2)
        case "*":
            return String(num1 * num2)
        case "/":
            return num2 != 0 ? String(num1 / num2) : nil
        case "^":
            return String(pow(num1, num2))
        default:
            return nil  // Invalid operator
        }
    } else {
        return nil  // Invalid operands
    }
}

private func isElementaryFunction(_ token: String) -> Bool {
    return token == "<sqrt>"
}

private func applyElementaryFunction(function: String, _ parameter: String) -> String? {
    if let param = Double(parameter) {
        switch function {
        case "<sqrt>":
            return String(param.squareRoot())
        default:
            return nil // Invalid elementary function
        }
    } else {
        return nil // Invalid parameter
    }
}
