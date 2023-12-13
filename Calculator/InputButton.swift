//
//  InputButton.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 12.12.23.
//

import SwiftUI

enum InputButtonType {
    case Number, Operation, Other
}

struct InputButton: View {
    let key: String
    let type: InputButtonType
    let action: () -> Void
    
    init(_ key: String, _ type: InputButtonType, action: @escaping () -> Void = {}) {
        self.key = key
        self.type = type
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(key)
                .font(.system(size: 32))
                .fontWeight(.medium)
                .foregroundStyle(self.type == .Other ? .black : .white)
                .frame(width: 80, height: 70)
                .background(backgroundColor())
                .cornerRadius(100)
        }
    }
    
    func backgroundColor() -> Color {
        switch type {
        case .Number:
            return Color(white: 0.30)
        case .Operation:
            return Color(red: 0.9, green: 0.6, blue: 0.03)
        case .Other:
            return Color(white: 0.7)
        }
    }
}

#Preview {
    InputButton("1", .Number) { print("Input button pressed") }
}
