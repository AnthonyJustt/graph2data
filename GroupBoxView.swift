//
//  GroupBoxView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 24.12.2021.
//

import SwiftUI

struct GroupBoxView: View {
    
    @State var boDate: Date //= Date()
    
    @State var boLOwerBound: Int // = 75
    @State var boHighestBound: Int // = 100
    @State var boMaxLevel: Int // = 100
    let range = 0...100
    
    var body: some View {
        GroupBox {
            DatePicker(selection: $boDate, in: ...Date(), displayedComponents: .date) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Text("Date")
                }
            }
            
            Divider()
            
            Stepper(value: $boLOwerBound, in: range, step: 1) {
                HStack {
                    Image(systemName: "arrow.down.to.line")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .pink)
                        .font(.title2)
                    Text("Lower bound is \(boLOwerBound)%")
                }
            }
            
            Divider()
            
            Stepper(value: $boHighestBound, in: range, step: 1) {
                HStack {
                    Image(systemName: "arrow.up.to.line")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.purple, .pink)
                        .font(.title2)
                    Text("Highest bound is \(boHighestBound)%")
                }
            }
            
            Divider()
            
            Stepper(value: $boMaxLevel, in: range, step: 1) {
                HStack {
                    Image(systemName: "arrow.up.square")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Max level is \(boMaxLevel)%")
                }
            }
        }
    }
}

struct GroupBoxView_Previews: PreviewProvider {
    static var previews: some View {
        GroupBoxView(boDate: Date(), boLOwerBound: 75, boHighestBound: 100, boMaxLevel: 100)
            .previewLayout(.sizeThatFits)
            .padding()
           // .preferredColorScheme(.dark)
    }
}
