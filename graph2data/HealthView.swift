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
        
        Text("Add data")
            .onTapGesture {
                didAddNewData(with: 1)
            }
    }
    
    func didAddNewData(with value: Double) {
        guard let sample = processHealthSample(with: value) else { return }
        
        healthStore?.saveHealthData([sample]) { (success, error) in
            if let error = error {
                print("DataTypeTableViewController didAddNewData error:", error.localizedDescription)
            }
            if success {
                print("Successfully saved a new sample!", sample)
    //                DispatchQueue.main.async { [weak self] in
    //                    self?.reloadData()
    //                }
            } else {
                print("Error: Could not save new sample.", sample)
            }
        }
    }

    private func processHealthSample(with value: Double) -> HKObject? {
        let dataTypeIdentifier = HKQuantityTypeIdentifier.oxygenSaturation.rawValue
        
        guard
            let sampleType = getSampleType(for: dataTypeIdentifier),
            let unit = preferredUnit(for: dataTypeIdentifier)
        else {
            return nil
        }
        
        //
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        //
        
        let now = dateFormatter.date(from: "2020-01-10T11:42:00") ?? Date()
        let start = now
        let end = now
        
        var optionalSample: HKObject?
        if let quantityType = sampleType as? HKQuantityType {
            let quantity = HKQuantity(unit: unit, doubleValue: value)
            let quantitySample = HKQuantitySample(type: quantityType, quantity: quantity, start: start, end: end)
            optionalSample = quantitySample
        }
        if let categoryType = sampleType as? HKCategoryType {
            let categorySample = HKCategorySample(type: categoryType, value: Int(value), start: start, end: end)
            optionalSample = categorySample
        }
        return optionalSample
    }
}



struct HealthView_Previews: PreviewProvider {
    static var previews: some View {
        HealthView()
    }
}
