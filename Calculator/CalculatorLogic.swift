//
//  CalculatorLogic.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 10.12.23.
//

import Foundation

struct Calculation: Identifiable {
    let id = UUID().uuidString
    let expression: String
    let result: String
}

var history: [Calculation] = []

public func evaluateMathExpression(_ expression: String, x: Double = Double.nan) -> String? {
    // Step 1: Tokenize the expression
    let tokens = tokenize(expression, x)

    // Step 2: Parse and evaluate the expression
    let result = parseAndEvaluate(tokens)

    return result
}

private func tokenize(_ expression: String, _ x: Double) -> [String] {
    var tokens: [String] = []
    var currentToken = ""

    for char in expression {
        if char.isNumber {
            currentToken.append(char)
        } else if char == "." {
            currentToken.append(char)
        } else if char == "e" {
            currentToken.append(char)
        } else if !currentToken.isEmpty && currentToken.last == "e" && (char == "+" || char == "-") {
            currentToken.append(char)
        } else if char == "-" && currentToken.isEmpty && tokens.isEmpty {
            currentToken.append(char)
        } else if char == "-" && currentToken.isEmpty && (tokens.isEmpty || (!tokens.isEmpty && Double(tokens.last!) == nil && tokens.last! != ")")) {
            currentToken.append(char)
        } else {
            if !currentToken.isEmpty && currentToken.first != "<" {
                tokens.append(currentToken)
                currentToken = ""
            }
            
            if char == "π" {
                if !tokens.isEmpty && shouldInsertMultiplicationToken(tokens.last!) {
                    tokens.append("*")
                }
                tokens.append(String(Double.pi))
            } else if char == "𝒆" {
                if !tokens.isEmpty && shouldInsertMultiplicationToken(tokens.last!) {
                    tokens.append("*")
                }
                tokens.append(String(M_E))
            } else if char == "≂" {
                if !tokens.isEmpty && shouldInsertMultiplicationToken(tokens.last!) {
                    tokens.append("*")
                }
                tokens.append(history.last?.result ?? "0")
            } else if char == "x" {
                if !tokens.isEmpty && shouldInsertMultiplicationToken(tokens.last!) {
                    tokens.append("*")
                }
                tokens.append(String(x))
            } else if char == "<" {
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
    
    // 1. Evaluate parentheses
    while let openingParenthesisIndex = tks.lastIndex(where: { $0 == "(" }) {
        if let closingParenthesisIndex = tks.enumerated().first(where: { $0.offset > openingParenthesisIndex && $0.element == ")" })?.offset {
            if openingParenthesisIndex + 1 == closingParenthesisIndex {
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
    }
    
    if tks.contains(where: { $0 == ")" }) {
        return nil // missing opening parenthesis '('
    }
    
    // 2. Evaluate elementary functions
    while let elemFuncIndex = tks.lastIndex(where: { isElementaryFunction($0) }) {
        
        if elemFuncIndex + 1 > tks.count - 1 {
            return nil // missing parameter
        }
        
        let elemFuncResult = applyElementaryFunction(function: tks[elemFuncIndex], tks[elemFuncIndex+1])
        
        if elemFuncResult == nil {
            return nil // couldn't apply the function
        }
        
        tks.remove(at: elemFuncIndex+1)
        tks[elemFuncIndex] = elemFuncResult!
    }
    
    // 3. Resolve negation
    for token in tks.enumerated().reversed() where token.element == "-" {
        if token.offset - 1 < 0 || (token.offset - 1 >= 0 && Double(tks[token.offset - 1]) == nil) {
            if token.offset + 1 < tks.count {
                if let number = Double(tks[token.offset + 1]) {
                    tks.remove(at: token.offset + 1)
                    tks[token.offset] = String(-number)
                }
            }
        }
    }
    
    // 4. Evaluate operations (ordered)
    while let op = tks.enumerated().first(where: { $0.element == "^" }) ?? tks.enumerated().first(where: { $0.element == "*" || $0.element == "/" }) ?? tks.enumerated().first(where: { isOperator($0.element) }) {
        
        if op.offset - 1 < 0 || op.offset + 1 > tks.count - 1 {
            return nil // missing operand
        }
        
        let operationResult = performOperation(tks[op.offset-1], operatorSymbol: op.element, tks[op.offset+1])
        
        if operationResult == nil {
            return nil // invalid operation
        }
        
        tks.remove(atOffsets: [op.offset, op.offset+1])
        tks[op.offset-1] = operationResult!
    }
    
    if tks.count > 1 { return nil } // missing operators
    
    if tks.isEmpty { return nil } // no result
    
    // 5. Return result
    return Double(tks.first!) == nil ? nil : tks.first
}

func isOperator(_ token: String) -> Bool {
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

func isElementaryFunction(_ token: String) -> Bool {
    return ["<sqrt>", "<sin>", "<cos>", "<tan>", "<csc>", "<sec>", "<cot>"].contains(token)
}

private func applyElementaryFunction(function: String, _ parameter: String) -> String? {
    if let param = Double(parameter) {
        switch function {
        case "<sqrt>":
            return String(param.squareRoot())
        case "<sin>":
            return String(sin(param))
        case "<cos>":
            return String(cos(param))
        case "<tan>":
            return String(tan(param))
        case "<csc>":
            return String(1/sin(param))
        case "<sec>":
            return String(1/cos(param))
        case "<cot>":
            return String(1/tan(param))
        default:
            return nil // Invalid elementary function
        }
    } else {
        return nil // Invalid parameter
    }
}

func shouldInsertMultiplicationToken(_ lastToken: String) -> Bool {
    !isOperator(lastToken) && !isElementaryFunction(lastToken) && lastToken != "("
}
