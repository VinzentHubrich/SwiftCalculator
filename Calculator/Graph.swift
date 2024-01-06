//
//  GraphView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 06.01.24.
//

import SwiftUI
import Charts

struct Graph: View {
    let expression: String = "x^2"
    
    var domainX: [Double] = [-10, 10]
    var domainY: [Double] = [-10, 10]
    let resolution: Int = 100

    private func frequency() -> Double {
        (domainX.last! - domainX.first!) / Double(resolution)
    }
    
    private func xValues() -> [Double] {
        Array(stride(from: domainX.first!, through: domainX.last!, by: frequency()))
    }
    
    private func calculateY(_ x: Double) -> Double {
        var expr: [String] = expression.map { String($0) }
        
        // Replace x and insert * operation if necessary
        while let index = expr.firstIndex(where: { $0 == "x" }) {
            if index > 0 && Double(expr[index-1]) != nil {
                expr[index] = "*\(x)"
            } else {
                expr[index] = String(x)
            }
        }
        
        let result = evaluateMathExpression(expr.joined())
        
        if result == nil {
            return Double.nan
        }
        
        return Double(result!)!
    }
    
    var body: some View {
        Chart {
            RuleMark(x: .value("", 0)).foregroundStyle(.black)
            RuleMark(y: .value("", 0)).foregroundStyle(.black)
            
            ForEach(xValues(), id: \.self) { x in
                LineMark(
                    x: .value("", x),
                    y: .value("", calculateY(x))
                )
                //.interpolationMethod(.monotone)
            }
        }
        .chartXScale(domain: domainX)
        .chartYScale(domain: domainY)
    }
}

#Preview {
    Graph()
}
