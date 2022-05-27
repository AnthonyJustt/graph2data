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
    var additionalColor: Color
    @Binding var isZooming: Bool
    @Binding var photoPickerIsPresented: Bool
    var mediaItems_Items_Count: Int
    var analyseAction: () -> Void
    var errorText: String
    
    @AppStorage("boLatestDate") var boLatestDate: String = ""
    
    @State private var showingAlert = false
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .symbolRenderingMode(.palette)
                .foregroundStyle(additionalColor, accentColor)
                .font(.system(size: 60))
                .offset(y: isZooming ? -200 : 0)
                .animation(.easeInOut, value: isZooming)
                .frame(width: 100, height: 72)
            
            if !boLatestDate.isEmpty && imageName == "lungs" {
                Text("Latest update was for **\(boLatestDate)**")
                    .font(.footnote)
            }
            
            HStack {
                Button("Select Images...", action: {
                    photoPickerIsPresented = true
                })
                .buttonStyle(customButton(fillColor: accentColor))
                
                if mediaItems_Items_Count > 0 {
                    Button("Analyse Images", action: {
                        analyseAction()
                    })
                    .accessibilityIdentifier("get_date")
                    .buttonStyle(customButton(fillColor: accentColor))
                }
            }
            
            HStack {
                if errorText.count > 0 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.title2)
                    Text("Attention required")
                }
            }
            .onTapGesture(perform: {
                showingAlert = true
            })
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(""),
                      message: Text(errorText
                        .replacingOccurrences(of: "recognizedImage", with: "recognized\nImage")
                        .replacingOccurrences(of: "dateImage", with: "date\nImage")),
                      dismissButton: .destructive(Text("OK")))
            }
            
        }
    }
}

struct HeaderView_Previews: PreviewProvider {
    @State static var isZooming = false
    @State static var photoPickerIsPresented = false
    static var previews: some View {
        //lungs
        HeaderView(imageName: "bolt.heart", accentColor: .pink, additionalColor: .orange, isZooming: $isZooming, photoPickerIsPresented: $photoPickerIsPresented, mediaItems_Items_Count: 1, analyseAction: {}, errorText: "77")
            .previewLayout(.sizeThatFits)
            .padding()
        //                    .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
