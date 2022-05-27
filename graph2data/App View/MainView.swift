//
//  MainView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 29.11.2021.
//

import SwiftUI

struct MainView: View {
    @State private var tabSelection = 2
    
    @State var width = UIScreen.main.bounds.width - 90
    @State var x = -UIScreen.main.bounds.width + 90
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            tabView
            
            SlideMenu()
                .shadow(color: Color.black.opacity(x != 0 ? 0.1 : 0), radius: 5, x: 5, y: 0)
                .offset(x: x)
                .background(Color.black.opacity(x == 0 ? 0.5 : 0)
                    .ignoresSafeArea(.all, edges: .vertical)
                    .onTapGesture {
                        withAnimation { x = -width }
                    })
        }
        .gesture(
            DragGesture()
                .onChanged({ value in
                    withAnimation {
                        if value.translation.width > 0 {
                            if x < 0 { x = -width + value.translation.width  }
                        } else { x = value.translation.width }
                    }
                })
                .onEnded({ value in
                    withAnimation {
                        if -x < width / 2 { x = 0 } else { x = -width }
                    }
                })
        )
    }
    
    var tabView: some View {
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
            WeightManagment()
                .tabItem {
                    Image(systemName: "lineweight")
                    Text(LocalizedStringKey("WeightManagment.Tab"))
                }.tag(2)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
