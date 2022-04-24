//
//  pixelsApp.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 18.09.2021.
//

import SwiftUI

@main
struct pixelsApp: App {
    @StateObject var model = Model()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(model)
          //   HealthView()
        }
    }
}
