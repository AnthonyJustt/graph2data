//
//  ExportButtonView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 04.01.2022.
//

import SwiftUI

struct ExportButtonView: View {
    var accentColor: Color
    var buttonAction: () -> Void
    var body: some View {
        Button(action: {
            buttonAction()
        }, label: {
            HStack {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(.secondary)
                    .font(.title2)
                Spacer()
                Text(LocalizedStringKey("MainView.ExportToAppleHealth"))
                Spacer()
            }
        })
            .buttonStyle(customButton(fillColor: accentColor))
    }
}

struct ExportButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ExportButtonView(accentColor: .pink, buttonAction: {})
            .previewLayout(.sizeThatFits)
            .padding()
        //                    .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
