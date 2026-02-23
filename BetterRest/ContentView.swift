//
//  ContentView.swift
//  BetterRest
//
//  Created by Radu Edward-Andrei on 22.02.2026.
//

import SwiftUI
import CoreML

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 0
    
    private var idealBedtime: Date? {
        calculateBedTime()
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 0){
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                        DatePicker(
                            "Please enter a time",
                            selection: $wakeUp,
                            displayedComponents: .hourAndMinute
                        )
                        .labelsHidden()
                }
                
                Section("Desired amount of sleep") {
                    Stepper(
                        "\(sleepAmount.formatted()) hours",
                        value: $sleepAmount,
                        in: 4...12
                    )
                }
                .font(.headline)
                
                Picker("Daily coffee intake", selection: $coffeeAmount) {
                    ForEach(0..<20) { coffeeCups in
                        Text("^[\(coffeeCups) cup](inflect: true)")
                    }
                }
                .font(.headline)
                
                Section("Ideal bed time") {
                    if let idealBedtime {
                        Text(idealBedtime.formatted(date: .omitted, time: .shortened))
                    } else {
                        Text("Sorry, there was a problem calculating your bedtime.")
                            
                    }
                }
                .font(.title2.weight(.semibold))
            }
            .navigationTitle("BetterRest")
        }
    }
    
    func calculateBedTime() -> Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents(
                [.hour, .minute],
                from: wakeUp
            )
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
        } catch {
            return nil
        }
    }
}

#Preview {
    ContentView()
}
