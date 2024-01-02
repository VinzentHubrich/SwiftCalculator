//
//  InputButton.swift
//  Calculator
//
//  Created by Vinzent Hubrich on 12.12.23.
//

import SwiftUI

enum InputButtonType {
    case Number, Operation, Control, Special
}

struct InputButton: View {
    let key: String
    let showsSystemImage: Bool
    let type: InputButtonType
    let action: () -> Void
    
    init(_ key: String, showsSystemImage: Bool = false, _ type: InputButtonType, action: @escaping () -> Void) {
        self.key = key
        self.showsSystemImage = showsSystemImage
        self.type = type
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            if showsSystemImage {
                Image(systemName: key)
                    .fontWeight(.semibold)
                    .imageScale(.large)
                    .frame(width: 80, height: self.type == .Special ? 40 : 70)
            } else {
                Text(key)
                    .font(.system(size: 32))
                    .fontWeight(.medium)
                    .frame(width: 80, height: self.type == .Special ? 40 : 70)
            }
        }
        .frame(maxWidth: 100)
        .foregroundStyle(self.type == .Control ? .black : .white)
        .background(backgroundColor())
        .cornerRadius(50)
    }
    
    func backgroundColor() -> Color {
        switch type {
        case .Number:
            return Color(white: 0.30)
        case .Operation:
            return Color(red: 0.9, green: 0.6, blue: 0.03)
        case .Control:
            return Color(white: 0.7)
        case .Special:
            return Color.clear
        }
    }
}

#Preview {
    InputButton("1", .Number) { print("Input button pressed") }
}
