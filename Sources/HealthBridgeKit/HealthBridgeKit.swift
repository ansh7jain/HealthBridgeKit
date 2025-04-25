//
//  HealthBridgeKit.swift
//  HealthKitFW
//
//  Created by apple on 25/04/25.
//

import Foundation
import HealthKit

@available(macOS 13.0, *)
@MainActor
public class HealthBridgeKit {
    public static let shared = HealthBridgeKit()
    private let healthStore = HKHealthStore()

    public func getStepCount(for date: Date, completion: @escaping (Double) -> Void) {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        let startOfDay = Calendar.current.startOfDay(for: date)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: date, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) {
            _, result, _ in
            guard let quantity = result?.sumQuantity() else {
                completion(0)
                return
            }
            let steps = quantity.doubleValue(for: HKUnit.count())
            completion(steps)
        }
        healthStore.execute(query)
    }
    
    public func requestAuthorization(completion: @escaping (Bool) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }

        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { success, error in
            completion(success)
        }
    }
}

