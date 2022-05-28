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
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(width: UIScreen.main.bounds.width - 90)
            .background(.ultraThinMaterial)
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
