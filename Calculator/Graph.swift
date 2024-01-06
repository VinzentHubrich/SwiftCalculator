//
//  GraphView.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 06.01.24.
//

import SwiftUI
import Charts

struct Point: Identifiable {
    var id = UUID().uuidString
    var x: Double
    var y: Double
}

struct Graph: View {
    let expression: String
    
    @State var points: [Point] = []
    
    var domainX: [Double] = [-10, 10]
    var domainY: [Double] = [-10, 10]
    let resolution: Int = 15
    let frequency: Double

    init(expression: String) {
        self.expression = expression
        self.frequency = (domainX.last! - domainX.first!) / Double(resolution)
    }
    
    private func calculatePoints() {
        var expr: [String] = expression.map { String($0) }
        
        // Insert * operation before x if necessary
        while let index = expr.firstIndex(where: { $0 == "x" }) {
            if index > 0 && Double(expr[index-1]) != nil {
                expr[index] = "*X"
            } else {
                expr[index] = "X"
            }
        }
        
        // Calculate values
        var values: [Point] = []
        
        for x in Array(stride(from: domainX.first!, through: domainX.last!, by: frequency)) {
            let result = evaluateMathExpression(String(expr.joined()).replacingOccurrences(of: "X", with: String(x)))
            
            if result == nil {
                values.append(Point(x: x, y: Double.nan))
            } else {
                values.append(Point(x: x, y: Double(result!)!))
            }
        }
        
        points = values
    }
    
    var body: some View {
        Chart {
            RuleMark(x: .value("", 0))
            RuleMark(y: .value("", 0))
            
            ForEach(points) { point in
                LineMark(
                    x: .value("", point.x),
                    y: .value("", point.y)
                )
                .foregroundStyle(.orange)
                .interpolationMethod(.monotone)
            }
        }
        .foregroundStyle(.white)
        .chartXScale(domain: domainX)
        .chartYScale(domain: domainY)
        .onAppear { calculatePoints() }
    }
}

#Preview {
    Graph(expression: "1/x").background(.black)
}
