//
//  HealthView.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 26.09.2021.
//

import SwiftUI
import HealthKit

struct HealthView: View {
    
    //   var date: Date //= Date()
    var type: String //= ""
    //  var healthValues: [healthItem] //= [healthItem(x: 0, y: 0, date: "", value: "")]
    
    var mediaItems: PickedMediaItems
    
    @State private var showingNoHealthAlert = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var healthStore: HealthStore? = HealthStore()
    //    init() {
    //        healthStore = HealthStore()
    //    }
    
    var body: some View {
        
        VStack {
            
            VStack {
                Text(type)
                    .bold()
                    .padding()
                
                Image(systemName: "heart.text.square.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.red, Color.clear)
                    .font(.system(size: 60))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .stroke(.red, lineWidth: 2)
                    )
            }
            
            Spacer()
            
            Button(action: {
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
                
            }, label: {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Spacer()
                    Text("Authorize HealthKit Access")
                    Spacer()
                }
            })
                .buttonStyle(customButton(fillColor: .gray))
                .padding()
            
            Divider()
                .padding()
            
            Button(action: {
                //
            }, label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Spacer()
                    Text("Add \(type) Data")
                    Spacer()
                }
            })
                .buttonStyle(customButton(fillColor: Color("AccentColor")))
                .opacity(type == "Heart Rate" ? 1 : 0)
                .padding()
            
            Button(action: {
                if mediaItems.items.count > 0 {
                    for item in mediaItems.items {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        let dday = dateFormatter.string(from: item.date)
                        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                        for value in item.boValues {
                            dateFormatter.dateFormat = "HH:mm:ss"
                            let inDate = dateFormatter.date(from: value.date)!
                            dateFormatter.dateFormat = "h:mm:ss a"
                            let outTime = dateFormatter.string(from: inDate)
                            
                            didAddNewData(with: Double(value.value)! / Double(100), datetime: "\(dday)T\(outTime)")
                        }
                    }
                }
            }, label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                        .font(.title2)
                    Spacer()
                    Text("Add \(type) Data")
                    Spacer()
                }
            })
                .buttonStyle(customButton(fillColor: .cyan))
                .opacity(type == "Blood Oxygen" ? 1 : 0)
                .padding()
            
            Spacer()
            
        }
        .overlay(
            ZStack {
                blurView(cornerRadius: 25)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 3)
                Image(systemName: "xmark")
            }
                .padding(.top, 15)
                .padding(.trailing, 15)
                .onTapGesture {
                    presentationMode.wrappedValue.dismiss()
                }
            , alignment: .topTrailing
        )
        .alert(isPresented: $showingNoHealthAlert) {
            Alert(title: Text("Health Data Unavailable"), message: Text("Unable to access health data on this device. Make sure you are using device with HealthKit capabilities."), dismissButton: .default(Text("OK")))
        }
    }
    
    func didAddNewData(with value: Double, datetime: String) {
        guard let sample = processHealthSample(with: value, datetime: datetime) else { return }
        
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
    
    private func processHealthSample(with value: Double, datetime: String) -> HKObject? {
        let dataTypeIdentifier = HKQuantityTypeIdentifier.oxygenSaturation.rawValue
        
        guard
            let sampleType = getSampleType(for: dataTypeIdentifier),
            let unit = preferredUnit(for: dataTypeIdentifier)
        else {
            return nil
        }
        
        //
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'h:mm:ss a" //"yyyy-MM-dd'T'HH:mm:ss"
        let now = dateFormatter.date(from: datetime)! //?? Date()
        
        //  let now = date // ?? Date()
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
        HealthView(type: "_type", mediaItems: PickedMediaItems())
    }
}
