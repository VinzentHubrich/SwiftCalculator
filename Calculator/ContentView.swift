//
//  ContentView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 09.12.23.
//

import SwiftUI

struct ContentView: View {
    @State var expression: String = "<sqrt>(5+<sqrt>16)"
    
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
