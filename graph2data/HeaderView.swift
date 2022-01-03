//
//  HeaderView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 03.01.2022.
//

import SwiftUI

struct HeaderView: View {
    var imageName: String
    var accentColor: Color
    @Binding var isZooming: Bool
    @Binding var photoPickerIsPresented: Bool
    var mediaItems_Items_Count: Int
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.orange, accentColor)
                .font(.system(size: 60))
                .offset(y: isZooming ? -200 : 0)
                .animation(.easeInOut, value: isZooming)
            
            HStack {
                Button("Select Images...", action: {
                    photoPickerIsPresented = true
                })
                    .buttonStyle(customButton(fillColor: accentColor))
                
                Button("Analyse Images", action: {
                    
                })
                    .buttonStyle(customButton(fillColor: accentColor))
                    .opacity(mediaItems_Items_Count == 0 ? 0 : 1)
            }
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    @State static var isZooming = false
    @State static var photoPickerIsPresented = false
    static var previews: some View {
        HeaderView(imageName: "bolt.heart", accentColor: .pink, isZooming: $isZooming, photoPickerIsPresented: $photoPickerIsPresented, mediaItems_Items_Count: 1)
            .previewLayout(.sizeThatFits)
            .padding()
//                    .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
