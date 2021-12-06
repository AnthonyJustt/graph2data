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
    
    var body: some View {
        
        GroupBox () {
            DisclosureGroup (DisclosureGroupName) {
                VStack(alignment: .leading) {
                    ForEach(hubArray) { item in
                        HStack {
                            Text("\(Int(item.x))")
                            Divider()
                            Text("\(Int(item.y))")
                            Divider()
                            Text(item.date)
                            Divider()
                            Text(item.value)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct DisclosureView_Previews: PreviewProvider {
    static var previews: some View {
        DisclosureView(hubArray: [healthItem(
            x: 0.0,
            y: 0.0,
            date: "00-00-0000",
            value: "123"
        )], DisclosureGroupName: "date here")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
