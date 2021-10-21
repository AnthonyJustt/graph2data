//
//  HealthView.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 26.09.2021.
//

import SwiftUI
import HealthKit

struct HealthView: View {
    
    @State private var showingNoHealthAlert = false
    
    private var healthStore: HealthStore?
    init() {
        healthStore = HealthStore()
    }
    
    var body: some View {
        Text("Authorize HealthKit Access")
            .alert(isPresented: $showingNoHealthAlert) {
                Alert(title: Text("Health Data Unavailable"), message: Text("Unable to access health data on this device. Make sure you are using device with HealthKit capabilities."), dismissButton: .default(Text("OK")))
            }
            .onTapGesture {
                print("Checking HealthKit authorization status...")
                
                if !HKHealthStore.isHealthDataAvailable() {
                    showingNoHealthAlert.toggle()
                    return
                }
                
                if let healthStore = healthStore {
                    healthStore.requestAuthorization { success in
                        
                    }
                }
                
                healthStore?.getRequestStatusForAuthorization() { success in
                    
                }
            }
    }
}

struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
