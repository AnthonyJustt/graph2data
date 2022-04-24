//
//  buttonStyle.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 03.12.2021.
//

import SwiftUI

struct customButton: ButtonStyle {
    
    var fillColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(height: 15)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(!configuration.isPressed ? fillColor : .red)
                    .opacity(0.1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(!configuration.isPressed ? fillColor : .red)
                    )
            )
    }
}
