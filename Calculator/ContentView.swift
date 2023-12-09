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

// Step 1: Tokenize the expression
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

// Step 2: Parse and evaluate the expression
func parseAndEvaluate(_ tokens: [String]) -> String? {
    var tks: [String] = tokens
    
    while tks.count > 1 {
        if let token = tks.enumerated().first(where: { isOperator($0.element) }) {
            if token.offset - 1 < 0 || token.offset + 1 > tks.count - 1 {
                return nil // missing operand
            }
            
            let operationResult = performOperation(tks[token.offset-1], operatorSymbol: token.element, tks[token.offset+1])
            
            if operationResult == nil {
                return nil // invalid operation
            }
            
            tks.remove(atOffsets: [token.offset, token.offset+1])
            tks[token.offset-1] = operationResult!
        } else {
            return nil // not enough operators
        }
    }
    
    if tks.first == nil {
        return nil // empty expression
    }

    return isOperator(tks.first!) ? nil : tks.first
}

func isOperator(_ token: String) -> Bool {
    return token == "+" || token == "-" || token == "*" || token == "/"
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
            if num2 != 0 {
                return String(num1 / num2)
            } else {
                return nil  // Division by zero
            }
        default:
            return nil  // Invalid operator
        }
    } else {
        return nil  // Invalid operands
    }
}

struct ContentView: View {
    @State var expression: String = "-1 + -1 + 5"
    
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
