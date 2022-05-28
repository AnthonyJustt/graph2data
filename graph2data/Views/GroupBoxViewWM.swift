//
//  GroupBoxViewWM.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 26.05.2022.
//

import SwiftUI

struct GroupBoxViewWM: View {
    @Binding var wmDate: Date //= Date()
    @Binding var wmTime: Date //= Date()
    @Binding var wmWeight: Float
    
    @Binding var wmBMI: Float
    @Binding var wmBFR: Float
    @Binding var wmFFM: Float
    
    @Binding var wmBMR: Float
    @Binding var wmBW: Float
    @Binding var wmVFL: Float
    
    @Binding var wmBMC: Float
    @Binding var wmP: Float
    @Binding var wmSMM: Float
    
    let wmRange = Float(0.0)...Float(150.0)
    
    var body: some View {
        VStack {
            GroupBox {
                HStack(spacing: 0) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                            .font(.title2)
                        Text("Date")
                    }
                    Spacer()
                    DatePicker(selection: $wmDate, displayedComponents: [.date], label: {})
                        .labelsHidden()
                    Spacer()
                    DatePicker(selection: $wmTime, displayedComponents: [.hourAndMinute], label: {})
                        .labelsHidden()
                }
                
                Divider()
                
                Stepper(value: $wmWeight, in: wmRange, step: Float(1.0)) {
                    HStack {
                        Image(systemName: "scalemass")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .pink)
                            .font(.title2)
                        let ss = String(format: "%.2f", wmWeight)
                        Text("Weight is **\(ss)**\(wmUnit.kg.rawValue)")
                    }
                }
                
                Divider()
                
                Stepper(value: $wmBMI, in: wmRange, step: Float(1.0)) {
                    HStack {
                        Image(systemName: "")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .pink)
                            .font(.title2)
                        let ss = String(format: "%.2f", wmBMI)
                        Text("BMI is **\(ss)**\(wmUnit.empty.rawValue)")
                    }
                }
                
                Divider()
                
                Stepper(value: $wmBFR, in: wmRange, step: Float(1.0)) {
                    HStack {
                        Image(systemName: "")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.blue, .pink)
                            .font(.title2)
                        let ss = String(format: "%.2f", wmBFR)
                        Text("Body fat rate is **\(ss)**\(wmUnit.percent.rawValue)")
                    }
                }
                
                Divider()
                
                wmEntry(image: "", text: "Fat-free mass is", value: wmFFM, unit: .kg)
            }
            
            GroupBox {
                wmEntry(image: "bolt.fill", text: "Basal metabolic rate is", value: wmBMR, unit: .kcal_per_day)
                Divider()
                wmEntry(image: "drop.fill", text: "Body water is", value: wmBW, unit: .percent)
                Divider()
                wmEntry(image: "", text: "Visceral fat level is", value: wmVFL, unit: .empty)
            }
            GroupBox {
                wmEntry(image: "", text: "Bone mineral content", value: wmBMC, unit: .kg)
                Divider()
                wmEntry(image: "", text: "Protein", value: wmP, unit: .percent)
                Divider()
                wmEntry(image: "figure.walk", text: "Skeletal muscle mass", value: wmSMM, unit: .kg)
            }
        }
    }
}

enum wmUnit: String {
    case kcal_per_day = " kcal/d"
    case percent = "%"
    case kg = " kg"
    case empty = ""
}

struct wmEntry: View {
    var image: String
    var text: String
    var value: Float
    var unit: wmUnit
    var body: some View {
        HStack {
            Image(systemName: image)
                .symbolRenderingMode(.palette)
                .foregroundStyle(.blue, .pink)
                .font(.title2)
            let ss = String(format: "%.2f", value)
            Text("\(text) **\(ss)**\(unit.rawValue)")
            Spacer()
        }
    }
}

struct GroupBoxViewWM_Previews: PreviewProvider {
    @State static var wmDate = Date()
    @State static var wmTime = Date()
    @State static var wmWM: Float = 0.0
    
    @State static var wmBMI: Float = 0.0
    @State static var wmBFR: Float = 0.0
    @State static var wmFFM: Float = 0.0
    
    @State static  var wmBMR: Float = 0.0
    @State static  var wmBW: Float = 0.0
    @State static  var wmVFL: Float = 0.0
    
    @State static  var wmBMC: Float = 0.0
    @State static  var wmP: Float = 0.0
    @State static  var wmSMM: Float = 0.0
    static var previews: some View {
        GroupBoxViewWM(wmDate: $wmDate, wmTime: $wmTime, wmWeight: $wmWM, wmBMI: $wmBMI, wmBFR: $wmBFR, wmFFM: $wmFFM, wmBMR: $wmBMR, wmBW: $wmBW, wmVFL: $wmVFL, wmBMC: $wmBMC, wmP: $wmP, wmSMM: $wmSMM)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
