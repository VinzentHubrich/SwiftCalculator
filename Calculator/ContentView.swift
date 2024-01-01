//
//  ContentView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 09.12.23.
//

import SwiftUI

private let symbolReplacements = ["/": "÷",
                                  "*": "∙",
                                  "-": "−",
                                  "(": "⟮",
                                  ")": "⟯",
                                  "<sqrt>": "√",
                                  "<ans>": "ANS",
                                  "x": "𝑥"]

struct ContentView: View {
    @State var expression: String = ""
    @State var shakeExpression: Bool = false
    @State private var displayingResult: Bool = false
    
    private func handleInput(_ key: String) {
        if displayingResult {
            if !isOperator(key) {
                expression.removeAll()
            }
            displayingResult = false
        }
        
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
    
    private func formatExpression(_ expression: String) -> String {
        var expr = expression
        
        for (symbol, replacement) in symbolReplacements {
            expr = expr.replacingOccurrences(of: symbol, with: replacement)
        }
        
        return expr
    }
    
    private func calculate() {
        if expression.isEmpty { return }
        
        if let result = evaluateMathExpression(expression) {
            history.append((expression, String(format: "%g", Double(result)!)))
            expression = String(format: "%g", Double(result)!)
            displayingResult = true
        } else {
            withAnimation(Animation.bouncy(duration: 0.3), { self.shakeExpression.toggle() })
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(expression.isEmpty ? "0" : formatExpression(expression))
                    .foregroundStyle(.white)
                    .font(.system(size: 50, weight: .light))
                    .modifier(ShakeEffect(animatableData: CGFloat(self.shakeExpression ? 1 : 0)))
            }
            .padding()
            
            Spacer()
            
            // Buttons
            VStack {
                HStack {
                    InputButton("x.squareroot", showsSystemImage: true, .Special) { handleInput("<sqrt>") }
                    Spacer()
                    InputButton("^", .Special) { handleInput("^") }
                    Spacer()
                    InputButton("𝑥", .Special) { handleInput("x") }
                    Spacer()
                    InputButton("ANS", .Special) { handleInput("<ans>") }
                }
                HStack {
                    InputButton("C", .Control) { expression.removeAll() }
                    Spacer()
                    InputButton("(", .Control) { handleInput("(") }
                    Spacer()
                    InputButton(")", .Control) { handleInput(")") }
                    Spacer()
                    InputButton("÷", .Operation) { handleInput("/") }
                }
                HStack {
                    InputButton("7", .Number) { handleInput("7") }
                    Spacer()
                    InputButton("8", .Number) { handleInput("8") }
                    Spacer()
                    InputButton("9", .Number) { handleInput("9") }
                    Spacer()
                    InputButton("×", .Operation) { handleInput("*") }
                }
                HStack {
                    InputButton("4", .Number) { handleInput("4") }
                    Spacer()
                    InputButton("5", .Number) { handleInput("5") }
                    Spacer()
                    InputButton("6", .Number) { handleInput("6") }
                    Spacer()
                    InputButton("−", .Operation) { handleInput("-") }
                }
                HStack {
                    InputButton("1", .Number) { handleInput("1") }
                    Spacer()
                    InputButton("2", .Number) { handleInput("2") }
                    Spacer()
                    InputButton("3", .Number) { handleInput("3") }
                    Spacer()
                    InputButton("＋", .Operation) { handleInput("+") }
                }
                HStack {
                    InputButton("0", .Number) { handleInput("0") }
                    Spacer()
                    InputButton(".", .Number) { handleInput(".") }
                    Spacer()
                    InputButton("DEL", .Number) { if expression.popLast() == ">" { while expression.popLast() != "<" {}} }
                    Spacer()
                    InputButton("=", .Operation) { calculate() }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat
    
    func modifier(_ x: CGFloat) -> CGFloat {
        3.5 * sin(x * .pi * 4)
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let transform = ProjectionTransform(CGAffineTransform(translationX: modifier(animatableData), y: 0))
        
        return transform
    }
}

#Preview {
    ContentView()
}
