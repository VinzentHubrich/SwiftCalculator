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
    
    @State private var points: [Point] = []
    @State private var domainX: [Double] = [-10, 10]
    @State private var domainY: [Double] = [-10, 10]
    @State private var frequency: Double = 1
    
    private let resolution: Int = 100
    private var center: Point = Point(x: 0, y: 0)
    private var xScale: Double = 20
    private let axisMarkStepSize: Double = 5

    init(expression: String) {
        self.expression = expression
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
        
        for step in Array(stride(from: domainX.first!, through: domainX.last!, by: frequency)) {
            let x = round(step * 1000) / 1000.0
            
            let result = evaluateMathExpression(String(expr.joined()).replacingOccurrences(of: "X", with: String(x)))
            
            if result == nil {
                values.append(Point(x: x, y: Double.nan))
            } else {
                // Pole check using 2 different approaches
                if values.last != nil && (abs(values.last!.y + Double(result!)!) < 0.01 * abs(values.last!.y) || abs(values.last!.y) * 5 < abs(Double(result!)!)) {
                    values.append(Point(x: values.last!.x + frequency/2, y: Double.nan))
                }
                
                values.append(Point(x: x, y: Double(result!)!))
            }
        }
        
        points = values
    }
    
    var body: some View {
        GeometryReader { geometry in
            Chart {
                Plot {
                    RuleMark(x: .value("", 0))
                    RuleMark(y: .value("", 0))
                }
                .lineStyle(StrokeStyle(lineWidth: 2.5))
                .foregroundStyle(.opacity(0.8))
                
                ForEach(points) { point in
                    LineMark(
                        x: .value("", point.x),
                        y: .value("", point.y)
                    )
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
                    .interpolationMethod(.monotone)
                }
            }
            .ignoresSafeArea()
            .foregroundStyle(.white)
            .chartXScale(domain: domainX)
            .chartYScale(domain: domainY)
            .chartXAxis {
                AxisMarks(
                    values: Array(stride(from: domainX.first!, through: domainX.last!, by: axisMarkStepSize))
                ) {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color(white: 0.4, opacity: 0.5))
                }
            }
            .chartYAxis {
                AxisMarks(
                    values: Array(stride(from: domainY.first!, through: domainY.last!, by: axisMarkStepSize))
                ) {
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 1)).foregroundStyle(Color(white: 0.4, opacity: 0.5))
                }
            }
            .onAppear {
                let ratio = geometry.size.height / geometry.size.width
                domainX = [center.x - xScale / 2, center.x + xScale / 2]
                domainY = [center.y - (xScale / 2) * ratio, center.y + (xScale / 2) * ratio]
                
                frequency = (domainX.last! - domainX.first!) / Double(resolution)
                
                calculatePoints()
            }
        }
    }
}

#Preview {
    Graph(expression: "1/x").background(.black)
}
