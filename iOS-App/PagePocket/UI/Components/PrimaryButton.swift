//
//  PrimaryButton.swift
//  PagePocket
//


import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(configuration.isPressed ? 0.7 : 1.0))
            )
            .foregroundStyle(.white)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    Button("Primary Button") {}
        .buttonStyle(PrimaryButtonStyle())
        .padding()
}

