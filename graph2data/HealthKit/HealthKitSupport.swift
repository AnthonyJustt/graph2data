//
//  HealthKitSupport.swift
//  graph2data
//
//  Created by Anton Krivonozhenkov on 03.12.2021.
//

import Foundation
import HealthKit

// MARK: Sample Type Identifier Support

/// Return an HKSampleType based on the input identifier that corresponds to an HKQuantityTypeIdentifier, HKCategoryTypeIdentifier
/// or other valid HealthKit identifier. Returns nil otherwise.
func getSampleType(for identifier: String) -> HKSampleType? {
    if let quantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier(rawValue: identifier)) {
        return quantityType
    }
    
    if let categoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier(rawValue: identifier)) {
        return categoryType
    }
    
    return nil
}

// MARK: - Unit Support

/// Return the appropriate unit to use with an HKSample based on the identifier. Asserts for compatible units.
func preferredUnit(for sampleIdentifier: String) -> HKUnit? {
    return preferredUnit(for: sampleIdentifier, sampleType: nil)
}

/// Returns the appropriate unit to use with an identifier corresponding to a HealthKit data type.
private func preferredUnit(for identifier: String, sampleType: HKSampleType? = nil) -> HKUnit? {
    var unit: HKUnit?
    let sampleType = sampleType ?? getSampleType(for: identifier)
    
    if sampleType is HKQuantityType {
        let quantityTypeIdentifier = HKQuantityTypeIdentifier(rawValue: identifier)
        
        switch quantityTypeIdentifier {
        case .heartRate:
            unit = .count()
        case .oxygenSaturation:
            unit = .percent()
        default:
            break
        }
    }
    
    return unit
}
