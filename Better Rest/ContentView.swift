//
//  ContentView.swift
//  Better Rest
//
//  Created by Adam Sayer on 24/7/2024.
//
import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack{
            Form {
                
                Section () {
                    Text("When do you want to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                Section () {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }
                
                Section() {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Picker("Amount of Coffee", selection: $coffeeAmount) {
                        ForEach(0...20, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                    
                }
                
                Section () {
                    Text("Optimal Bedtime")
                        .font(.headline)
                    if let sleepTime = calculateBedTime() {
                        Text(sleepTime.formatted(date: .omitted, time: .shortened))
                    } else {
                        Text("Calculating...")  // Display a placeholder while calculating
                    }
                }
            }
            .navigationTitle("Better Rest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {
                    showingAlert = false
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime() -> Date? {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let componets = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (componets.hour ?? 0) * 60 * 60
            let minute = (componets.minute ?? 0 ) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
            return nil
        }
        
    }
}

#Preview {
    ContentView()
}
