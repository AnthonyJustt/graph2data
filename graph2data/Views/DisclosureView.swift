//
//  DisclosureView.swift
//  DisclosureView
//
//  Created by Anton Krivonozhenkov on 20.09.2021.
//

import SwiftUI

struct DisclosureView: View {
    var hubArray: [ healthItem ]
    var DisclosureGroupName: String = ""
    var accentColor: Color
    
    var columns: [GridItem] = [
        GridItem(.fixed(60), spacing: 6),
        GridItem(.fixed(60), spacing: 6),
        GridItem(.fixed(100), spacing: 6),
        GridItem(.fixed(75), spacing: 6)
    ]
    
    var hiMin: Int
    var hiMax: Int
    
    var body: some View {
        
        GroupBox () {
            DisclosureGroup (DisclosureGroupName) {
                
                LazyVGrid(
                    columns: columns,
                    alignment: .center,
                    spacing: 16,
                    pinnedViews: [.sectionHeaders, .sectionFooters]
                ) {
                    //  Section(header: Text("Section 1").font(.title))
                    //   {
                    ForEach(hubArray) { index in
                        Text("\(Int(index.x))")
                        Text("\(Int(index.y))")
                        Text(index.date)
                        Text("\(index.value)")
                    }
                    //  }
                }
                .padding(.top)
                //      Text("Lowest — \(hiMin)%\nHighest — \(hiMax)%")
                Divider()
                    .padding(.horizontal)
                Text("Lowest — **\(hiMin)**%")
                Text("Highest — **\(hiMax)**%")
            }
            .accentColor(accentColor)
            
            //            Button(action: {
            //                let boMaxHI = hubArray.max { $0.value < $1.value }
            //                boMax = boMaxHI?.value ?? 0
            //
            //                let boMinHI = hubArray.min { $0.value < $1.value }
            //                boMin = boMinHI?.value ?? 0
            //            }, label: {
            //                Text("min-max")
            //            })
        }
    }
}

struct DisclosureView_Previews: PreviewProvider {
    static var previews: some View {
        DisclosureView(hubArray: [
            healthItem(
                x: 233,
                y: 800,
                date: "00:11:00",
                value: 77
            ),
            healthItem(
                x: 2166,
                y: 800,
                date: "08:14:00",
                value: 123
            )], DisclosureGroupName: "January 14, 2022", accentColor: .cyan, hiMin: 80, hiMax: 100)
        .previewLayout(.sizeThatFits)
        .padding()
        
        //         .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
