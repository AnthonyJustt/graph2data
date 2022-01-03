//
//  GroupBoxViewHR.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 04.01.2022.
//

import SwiftUI

struct GroupBoxViewHR: View {
    @Binding var hrDate: Date
    @Binding var hrRateMin: Int
    @Binding var hrRateMax: Int
    @Binding var hrRateStart: Int
    @Binding var hrRateEnd: Int
    
    var body: some View {
        GroupBox {
            DatePicker(selection: $hrDate, in: ...Date(), displayedComponents: .date) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Text("Date")
                }
            }
            
            Divider()
            Stepper(value: $hrRateMin) {
                HStack {
                    Image(systemName: "arrow.down.heart")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.blue, .pink)
                        .font(.title2)
                    Text("Min HR is \(hrRateMin) bpm")
                }
            }
            Divider()
            Stepper(value: $hrRateMax) {
                HStack {
                    Image(systemName: "arrow.up.heart")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.purple, .pink)
                        .font(.title2)
                    Text("Max HR is \(hrRateMax) bpm")
                }
            }
            Divider()
            Stepper(value: $hrRateStart) {
                HStack {
                    Image(systemName: "heart.circle")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("Start HR is \(hrRateStart) bpm")
                }
            }
            Divider()
            Stepper(value: $hrRateEnd) {
                HStack {
                    Image(systemName: "heart.circle.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                    Text("End HR is \(hrRateEnd) bpm")
                }
            }
        }
    }
}

struct GroupBoxViewHR_Previews: PreviewProvider {
    @State static var hrDate = Date()
    @State static var hrRateMin = 40
    @State static var hrRateMax = 120
    @State static var hrRateStart = 50
    @State static var hrRateEnd = 100
    static var previews: some View {
        GroupBoxViewHR(hrDate: $hrDate, hrRateMin: $hrRateMin, hrRateMax: $hrRateMax, hrRateStart: $hrRateStart, hrRateEnd: $hrRateEnd)
            .previewLayout(.sizeThatFits)
            .padding()
//                    .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
