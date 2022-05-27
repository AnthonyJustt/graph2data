//
//  SlideMenu.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 27.05.2022.
//

import SwiftUI

struct SlideMenu: View {
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading) {
                Spacer()
                Text("Menu")
                Spacer()
            }
            .padding(.horizontal, 20)
            // since vertical edges are ignored
            //   .padding(.top, edges!.top == 0 ? 15 : edges?.top)
            //   .padding(.bottom, edges!.bottom == 0 ? 15 : edges?.bottom)
            // default width
            .frame(width: UIScreen.main.bounds.width - 90)
            .background(Color(UIColor.systemBackground))
            .ignoresSafeArea(.all, edges: .vertical)
            
            Spacer(minLength: 0)
        }
    }
}

struct SlideMenu_Previews: PreviewProvider {
    static var previews: some View {
        SlideMenu()
    }
}
