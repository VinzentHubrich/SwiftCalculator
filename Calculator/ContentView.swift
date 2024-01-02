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
    @State private var shakeExpression: Bool = false
    @State private var displayingResult: Bool = false
    @State private var showInputMenu: Bool = false
    
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
            ZStack(alignment: .top) {
                // Standard Buttons
                Grid(horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow {
                        InputButton("C", .Control) { expression.removeAll() }
                        InputButton("(", .Control) { handleInput("(") }
                        InputButton(")", .Control) { handleInput(")") }
                        InputButton("÷", .Operation) { handleInput("/") }
                    }
                    GridRow {
                        InputButton("7", .Number) { handleInput("7") }
                        InputButton("8", .Number) { handleInput("8") }
                        InputButton("9", .Number) { handleInput("9") }
                        InputButton("×", .Operation) { handleInput("*") }
                    }
                    GridRow {
                        InputButton("4", .Number) { handleInput("4") }
                        InputButton("5", .Number) { handleInput("5") }
                        InputButton("6", .Number) { handleInput("6") }
                        InputButton("−", .Operation) { handleInput("-") }
                    }
                    GridRow {
                        InputButton("1", .Number) { handleInput("1") }
                        InputButton("2", .Number) { handleInput("2") }
                        InputButton("3", .Number) { handleInput("3") }
                        InputButton("＋", .Operation) { handleInput("+") }
                    }
                    GridRow {
                        InputButton("0", .Number) { handleInput("0") }
                        InputButton(".", .Number) { handleInput(".") }
                        InputButton("delete.backward.fill", showsSystemImage: true, .Number) { if expression.popLast() == ">" { while expression.popLast() != "<" {}} }
                        InputButton("=", .Operation) { calculate() }
                    }
                }
                .padding()
                
                // Input Menu
                Grid(horizontalSpacing: 12, verticalSpacing: 8) {
                    GridRow {
                        InputButton("x.squareroot", showsSystemImage: true, .Special) { handleInput("<sqrt>") }
                        InputButton("^", .Special) { handleInput("^") }
                        InputButton("𝑥", .Special) { handleInput("x") }
                        InputButton(showInputMenu ? "xmark" : "ellipsis", showsSystemImage: true, .Special) { withAnimation { showInputMenu.toggle() } }
                    }
                    GridRow {
                        InputButton("ANS", .Special) { handleInput("<ans>") }
                    }
                }
                .padding()
                .frame(height: showInputMenu ? CGFloat.nan : 50, alignment: .top)
                .background(showInputMenu ? Color(white: 0.2, opacity: 0.9) : Color.clear)
                .contentShape(Rectangle())
                .clipShape(RoundedRectangle(cornerRadius: showInputMenu ? 30 : 0))
                .shadow(color: showInputMenu ? .black : Color.clear, radius: 20, x: 0, y: 10)
                .offset(y: -50)
            }
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
