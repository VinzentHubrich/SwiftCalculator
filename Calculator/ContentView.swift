//
//  ContentView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 09.12.23.
//

import SwiftUI

private let symbolReplacements = [" ": "",
                                  "/": "÷",
                                  "*": "∙",
                                  "-": "−",
                                  "(": "⟮",
                                  ")": "⟯",
                                  "<sqrt>": "√",
                                  "<sin>": "sin",
                                  "<cos>": "cos",
                                  "<tan>": "tan",
                                  "<csc>": "csc",
                                  "<sec>": "sec",
                                  "<cot>": "cot",
                                  "≂": "ANS",
                                  "x": "𝑥"]

struct ContentView: View {
    @State var expression: String = ""
    @State private var shakeExpression: Bool = false
    @State private var displayingResult: Bool = false
    @State private var showInputMenu: Bool = false
    @State private var showHistory: Bool = false
    
    @Namespace private var graphNamespace
    @State private var showFullscreenGraph = false
    
    private func handleInput(_ input: String) {
        if displayingResult {
            if !isOperator(input) {
                expression.removeAll()
            }
            displayingResult = false
        }
        
        if input == "_delete_" {
            withAnimation(.linear(duration: 0.1)) { if expression.popLast() == ">" { while expression.popLast() != "<" {} } }
            return
        }
        
        if expression.isEmpty {
            if input == "." {
                expression.append("0.")
            } else if input != "0" {
                expression.append(input)
            }
        } else {
            withAnimation(.linear(duration: 0.1)) { expression.append(input) }
        }
    }
    
    private func formatExpression(_ expression: String) -> String {
        var expr = expression
        
        for (symbol, replacement) in symbolReplacements {
            expr = expr.replacingOccurrences(of: symbol, with: replacement)
        }
        
        return expr.isEmpty ? "0" : expr
    }
    
    private func calculate() {
        if expression.isEmpty { return }
        
        let result = evaluateMathExpression(expression)
        
        if result == nil || Double(result!)!.isNaN { // nil -> Syntax Error | NaN -> Math Error
            return withAnimation(Animation.bouncy(duration: 0.3), { self.shakeExpression.toggle() })
        }
        
        if history.last?.expression != expression {
            history.append(Calculation(expression: expression, result: String(format: "%g", Double(result!)!)))
        }
        
        expression = String(format: "%g", Double(result!)!)
        displayingResult = true
    }
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    // Graph
                    if expression.contains("x")  {
                        HStack {
                            Graph(expression: expression)
                                .mask {
                                    LinearGradient(gradient: Gradient(stops: [
                                        .init(color: Color.clear, location: 0),
                                        .init(color: Color.white, location: 0.2),
                                        .init(color: Color.white, location: 0.8),
                                        .init(color: Color.clear, location: 1)
                                    ]),
                                                   startPoint: .leading,
                                                   endPoint: .trailing
                                    )
                                }
                                .mask {
                                    LinearGradient(gradient: Gradient(stops: [
                                        .init(color: Color.clear, location: 0),
                                        .init(color: Color.white, location: 0.2),
                                        .init(color: Color.white, location: 0.8),
                                        .init(color: Color.clear, location: 1)
                                    ]),
                                                   startPoint: .top,
                                                   endPoint: .bottom
                                    )
                                }
                                .frame(width: 300)
                                .offset(x: -20)
                                .ignoresSafeArea()
                                .matchedGeometryEffect(id: "graph", in: graphNamespace)
                                .onTapGesture {
                                    withAnimation { showFullscreenGraph.toggle() }
                                }
                            
                            Spacer()
                        }
                    }
                    
                    // Calculator Display
                    VStack {
                        HStack {
                            Spacer()
                            Text(formatExpression(expression))
                                .background(Color(white: 0, opacity: 0.7))
                                .foregroundStyle(.white)
                                .font(.system(size: 50, weight: .light))
                                .modifier(ShakeEffect(animatableData: CGFloat(self.shakeExpression ? 1 : 0)))
                        }
                        
                        Spacer()
                    }
                    .padding()
                    
                    // Invisible rectangle to detect touch outside of the input menu.
                    if showInputMenu {
                        Rectangle()
                            .opacity(1e-5)
                            .layoutPriority(-1)
                            .onTapGesture { withAnimation { showInputMenu = false } }
                    }
                }
                
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
                            InputButton("delete.backward.fill", showsSystemImage: true, .Number) { handleInput("_delete_") }
                            InputButton("=", .Operation) { calculate() }
                        }
                    }
                    .padding()
                    
                    // Rectangle to detect touch outside of the input menu. Also darkens the numpad.
                    if showInputMenu {
                        Rectangle()
                            .fill(.black)
                            .opacity(0.1)
                            .layoutPriority(-1)
                            .onTapGesture { withAnimation { showInputMenu = false } }
                    }
                    
                    // Input Menu
                    Grid(horizontalSpacing: 12, verticalSpacing: 8) {
                        GridRow {
                            InputButton("x.squareroot", showsSystemImage: true, .Special) { handleInput("<sqrt>") }
                            InputButton("^", .Special) { handleInput("^") }
                            InputButton("𝑥", .Special) { handleInput("x") }
                            InputButton(showInputMenu ? "xmark" : "ellipsis", showsSystemImage: true, .Special) { withAnimation { showInputMenu.toggle() } }.contentTransition(.symbolEffect(.replace))

                        }
                        GridRow {
                            InputButton("π", .Special) { handleInput("π") }
                            InputButton("sin", .Special) { handleInput("<sin>") }
                            InputButton("cos", .Special) { handleInput("<cos>") }
                            InputButton("tan", .Special) { handleInput("<tan>") }
                        }
                        GridRow {
                            InputButton("𝒆", .Special) { handleInput("𝒆") }
                            InputButton("csc", .Special) { handleInput("<csc>") }
                            InputButton("sec", .Special) { handleInput("<sec>") }
                            InputButton("cot", .Special) { handleInput("<cot>") }
                        }
                        GridRow {
                            InputButton("ANS", .Special) { handleInput("≂") }
                            InputButton("clock.arrow.circlepath", showsSystemImage: true, .Special) {
                                withAnimation { showInputMenu = false }
                                showHistory = true
                            }
                        }
                    }
                    .padding()
                    .frame(height: showInputMenu ? .none : 50, alignment: .top)
                    .background(showInputMenu ? Color(white: 0.2, opacity: 0.9) : Color.clear)
                    .contentShape(Rectangle())
                    .clipShape(RoundedRectangle(cornerRadius: showInputMenu ? 30 : 0))
                    .shadow(color: showInputMenu ? .black : Color.clear, radius: 20, x: 0, y: 10)
                    .offset(y: -50)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .sheet(isPresented: $showHistory) {
                VStack {
                    HStack {
                        Spacer()
                        Button("", systemImage: "xmark") {
                            showHistory = false
                        }
                        .foregroundStyle(.white)
                        .imageScale(.large)
                    }
                    
                    Spacer()
                    
                    ScrollView {
                        ForEach(history.reversed()) { calculation in
                            VStack {
                                HStack {
                                    Text(formatExpression(calculation.expression))
                                        .onTapGesture {
                                            expression = calculation.expression
                                            showHistory = false
                                        }
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    Text(formatExpression(calculation.result))
                                        .onTapGesture {
                                            expression = calculation.result
                                            showHistory = false
                                        }
                                }
                                if calculation.id != history.first?.id {
                                    Divider()
                                        .frame(height: 2)
                                        .overlay(Color(white: 0.3))
                                }
                            }
                            .font(.system(size: 40, weight: .light))
                        }
                    }
                    .scrollIndicators(.hidden)
                }
                .padding()
                .foregroundStyle(.white)
                .presentationBackground(.regularMaterial).preferredColorScheme(.dark)
                .presentationDetents([.fraction(0.6)])
                .presentationCornerRadius(30)
                .interactiveDismissDisabled()
                .ignoresSafeArea()
            }
            
            // Fullscreen Graph
            if showFullscreenGraph {
                Graph(expression: expression)
                    .matchedGeometryEffect(id: "graph", in: graphNamespace)
                    .background(.regularMaterial).preferredColorScheme(.dark)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { showFullscreenGraph.toggle() }
                    }
            }
        }
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
