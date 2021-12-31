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
    
    var columns: [GridItem] = [
        GridItem(.fixed(60), spacing: 6),
        GridItem(.fixed(60), spacing: 6),
        GridItem(.fixed(100), spacing: 6),
        GridItem(.fixed(75), spacing: 6)
    ]
    
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
                            Text(index.value)
                        }
                  //  }
                }
                .padding(.top)
            }
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
                value: "77"
            ),
            healthItem(
                x: 2166,
                y: 800,
                date: "08:14:00",
                value: "123"
            )], DisclosureGroupName: "December 14, 2021")
            .previewLayout(.sizeThatFits)
            .padding()
        
//         .preferredColorScheme(.dark)
        // .environment(\.locale, .init(identifier: "ru"))
    }
}
