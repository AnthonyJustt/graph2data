//
//  HealthStore.swift
//  pixels
//
//  Created by Anton Krivonozhenkov on 26.09.2021.
//

import Foundation
import HealthKit

class HealthStore {
    var healthStore: HKHealthStore?
    
    var hasRequestedHealthData: Bool = false
    
    var shareDataTypes: [HKSampleType] {
        return allHealthDataTypes
    }
    
    var allHealthDataTypes: [HKSampleType] {
        let typeIdentifiers: [String] = [
            HKQuantityTypeIdentifier.heartRate.rawValue,
            HKQuantityTypeIdentifier.oxygenSaturation.rawValue
        ]
        
        return typeIdentifiers.compactMap { getSampleType(for: $0) }
    }
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else
        { fatalError("This app requires a device that supports HealthKit")
            
        }
        healthStore = HKHealthStore()
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let hrType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let osType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
        guard let healthStore = self.healthStore else {
            return completion(false)
        }
        healthStore.requestAuthorization(toShare: [hrType, osType], read: [hrType, osType]) { (success, error) in
            print("Request Authorization -- Success: ", completion(success), " Error: ", error ?? "nil")
            // Handle authorization errors here.
        }
    }
    
    func getRequestStatusForAuthorization(completion: @escaping (Bool) -> Void) {
        let hrType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let osType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.oxygenSaturation)!
        
        guard let healthStore = self.healthStore else {
            return completion(false)
        }
        
        let shareTypes = Set(self.shareDataTypes)
        
        healthStore.getRequestStatusForAuthorization(toShare: [hrType, osType], read: [hrType, osType]) { (authorizationRequestStatus, error) in
            var status: String = ""
            if let error = error {
                status = "HealthKit Authorization Error: \(error.localizedDescription)"
            } else {
                switch authorizationRequestStatus {
                case .shouldRequest:
                    self.hasRequestedHealthData = false
                    
                    status = "The application has not yet requested authorization for all of the specified data types."
                case .unknown:
                    status = "The authorization request status could not be determined because an error occurred."
                case .unnecessary:
                    self.hasRequestedHealthData = true
                    
                    status = "The application has already requested authorization for the specified data types. "
                    status += self.createAuthorizationStatusDescription(for: shareTypes)
                default:
                    break
                }
            }
            
            print(status)
        }
    }
    
    private func createAuthorizationStatusDescription(for types: Set<HKObjectType>) -> String {
        var dictionary = [HKAuthorizationStatus: Int]()
        
        guard let healthStore = self.healthStore else {
            return "nil"
        }
        
        for type in types {
            let status = healthStore.authorizationStatus(for: type)
            
            if let existingValue = dictionary[status] {
                dictionary[status] = existingValue + 1
            } else {
                dictionary[status] = 1
            }
        }
        
        var descriptionArray: [String] = []
        
        if let numberOfAuthorizedTypes = dictionary[.sharingAuthorized] {
            let format = NSLocalizedString("AUTH - %ld", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfAuthorizedTypes])
            
            descriptionArray.append(formattedString)
        }
        if let numberOfDeniedTypes = dictionary[.sharingDenied] {
            let format = NSLocalizedString("DENIED - %ld", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfDeniedTypes])
            
            descriptionArray.append(formattedString)
        }
        if let numberOfUndeterminedTypes = dictionary[.notDetermined] {
            let format = NSLocalizedString("UNDETERMINED - %ld", comment: "")
            let formattedString = String(format: format, locale: .current, arguments: [numberOfUndeterminedTypes])
            
            descriptionArray.append(formattedString)
        }
        
        // Format the sentence for grammar if there are multiple clauses.
        if let lastDescription = descriptionArray.last, descriptionArray.count > 1 {
            descriptionArray[descriptionArray.count - 1] = "and \(lastDescription)"
        }
        
        let description = "Sharing is " + descriptionArray.joined(separator: ", ") + "."
        
        return description
    }
    
    // MARK: - HKHealthStore
    
   func saveHealthData(_ data: [HKObject], completion: @escaping (_ success: Bool, _ error: Error?) -> Void) {
        healthStore?.save(data, withCompletion: completion)
    }
    
}


