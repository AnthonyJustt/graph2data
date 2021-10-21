//
//  DisclosureView.swift
//  DisclosureView
//
//  Created by Anton Krivonozhenkov on 20.09.2021.
//

import SwiftUI

struct heartRateItem: Identifiable {
    var id = UUID()
    var date: String
    var hr: String
}

struct DisclosureView: View {
    var hubArray: [ heartRateItem ]
    var DisclosureGroupName: String = ""
    
    var body: some View {
        
        GroupBox () {
            DisclosureGroup (DisclosureGroupName) {
                VStack(alignment: .leading) {
                    ForEach(hubArray) { item in
                        HStack {
                            Text(item.date)
                            Spacer()
                            Text(item.hr)
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
        DisclosureView(hubArray: [heartRateItem(date: "11", hr: "22"), heartRateItem(date: "33", hr: "44")], DisclosureGroupName: "date here")
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
