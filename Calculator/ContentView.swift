//
//  ContentView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 09.12.23.
//

import SwiftUI

struct ContentView: View {
    @State var expression: String = ""
    
    private func handleInput(_ key: String) {
        if expression.isEmpty {
            if key == "." {
                expression.append("0")
            } else if key == "+" || key == "*" || key == "/" || key == "0" {
                return
            }
        } else {
            if key == "." && Double(String(expression.last!)) == nil { return }
            
            if isOperator(key) && isOperator(String(expression.last!)) {
                if expression.count > 2 && isOperator(String(expression[expression.index(expression.endIndex, offsetBy: -2)])) {
                    if key == "/" || key == "*" {
                        expression.removeLast(2)
                    } else if key == "-" || key == "+" {
                        expression.removeLast()
                        return
                    }
                } else if !(key == "-" && (expression.last! == "/" || expression.last! == "*")) {
                    expression.removeLast()
                }
            }
        }
        
        expression.append(key)
    }
    
    private func calculate() {
        if expression.isEmpty { return }
        
        if let result = evaluateMathExpression(expression) {
            expression = result
        } else {
            print("Invalid expression")
        }
    }
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text(expression.isEmpty ? "0" : expression)
                .foregroundStyle(.white)
                .font(.system(size: 50, weight: .light))
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    InputButton("C", .Other) { expression.removeAll() }
                    InputButton("(", .Other) { handleInput("(") }
                    InputButton(")", .Other) { handleInput(")") }
                    InputButton(":", .Operation) { handleInput("/") }
                    
                }
                HStack {
                    InputButton("7", .Number) { handleInput("7") }
                    InputButton("8", .Number) { handleInput("8") }
                    InputButton("9", .Number) { handleInput("9") }
                    InputButton("x", .Operation) { handleInput("*") }
                    
                }
                HStack {
                    InputButton("4", .Number) { handleInput("4") }
                    InputButton("5", .Number) { handleInput("5") }
                    InputButton("6", .Number) { handleInput("6") }
                    InputButton("-", .Operation) { handleInput("-") }
                    
                }
                HStack {
                    InputButton("1", .Number) { handleInput("1") }
                    InputButton("2", .Number) { handleInput("2") }
                    InputButton("3", .Number) { handleInput("3") }
                    InputButton("+", .Operation) { handleInput("+") }
                }
                HStack {
                    InputButton("0", .Number) { handleInput("0") }
                    InputButton(".", .Number) { handleInput(".") }
                    InputButton("DEL", .Number) { _ = expression.popLast() }
                    InputButton("=", .Operation) { calculate() }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    ContentView()
}
