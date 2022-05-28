//
//  MainView.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 29.11.2021.
//

import SwiftUI

struct MainView: View {
    @State private var tabSelection = 1
    @State var x = -UIScreen.main.bounds.width
    var body: some View {
        ZStack() {
            tabView
            
            SlideMenu()
                .shadow(color: Color.black.opacity(x != 0 ? 0.1 : 0), radius: 5, x: 5, y: 0)
                .offset(x: x)
                .background(Color.white.opacity(x == 0 ? 0.01 : 0)
                    .offset(x: x == 0 ? UIScreen.main.bounds.width - 90 : UIScreen.main.bounds.width)
                    .ignoresSafeArea(.all, edges: .vertical)
                    .onTapGesture {
                        withAnimation { x = -UIScreen.main.bounds.width }
                    })
            
            Image(systemName: x == 0 ? "chevron.compact.left" : "chevron.compact.right")
                .font(.largeTitle)
                .padding(8)
                .padding(.vertical, 16)
                .background(
                    RoundedCornersShape(corners: [.topRight, .bottomRight], radius: 15)
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: x == 0 ? .clear : .gray.opacity(0.3), radius: x == 0 ? 0 : 5)
                .position(x: x == 0 ? UIScreen.main.bounds.width - 90 + 16 : 16, y: 100)
                .onTapGesture {
                    withAnimation {
                        if x == 0 { x = -UIScreen.main.bounds.width } else { x = 0 }
                    }
                }
        }
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

struct RoundedCornersShape: Shape {
    let corners: UIRectCorner
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
