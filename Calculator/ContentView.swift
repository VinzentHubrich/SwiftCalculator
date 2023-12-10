//
//  ContentView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 09.12.23.
//

import SwiftUI

func evaluateMathExpression(_ expression: String) -> String? {
    // Step 1: Tokenize the expression
    let tokens = tokenize(expression)

    // Step 2: Parse and evaluate the expression
    let result = parseAndEvaluate(tokens)

    return result
}

func tokenize(_ expression: String) -> [String] {
    var tokens: [String] = []
    var currentToken = ""

    for char in expression {
        if (char.isNumber || char == ".") || (char == "-" && currentToken.isEmpty) {
            currentToken.append(char)
        } else {
            if !currentToken.isEmpty {
                tokens.append(currentToken)
                currentToken = ""
            }

            if char != " " {
                tokens.append(String(char))
            }
        }
    }

    if !currentToken.isEmpty {
        tokens.append(currentToken)
    }

    return tokens
}

func parseAndEvaluate(_ tokens: [String]) -> String? {
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

    return isOperator(tks.first!) || tks.first! == "(" || tks.first! == ")" ? nil : tks.first
}

func isOperator(_ token: String) -> Bool {
    return token == "+" || token == "-" || token == "*" || token == "/" || token == "^"
}

func performOperation(_ operand1: String, operatorSymbol: String, _ operand2: String) -> String? {
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

struct ContentView: View {
    @State var expression: String = "0--(-(1+1)--(2+-(-2)))"
    
    var body: some View {
        VStack {
            Text(expression)
            VStack {
                HStack {
                    Button("=") {
                        if let result = evaluateMathExpression(expression) {
                            print("Result: \(result)")
                        } else {
                            print("Invalid expression")
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
