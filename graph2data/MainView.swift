//
//  MainView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 29.11.2021.
//

import SwiftUI

struct MainView: View {
    @State private var tabSelection = 1
    var body: some View {
        TabView(selection: $tabSelection) {
            HeartRate()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text(LocalizedStringKey("HeartRate.Title"))
                }.tag(0)
            BloodOxygen()
                .tabItem {
                    Image(systemName: "lungs.fill")
                    Text(LocalizedStringKey("BloodOxygen.Tab"))
                }.tag(1)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
