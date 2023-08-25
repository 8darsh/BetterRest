//
//  ContentView.swift
//  BetterRest
//
//  Created by Adarsh Singh on 08/03/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmt = 8.0
    @State private var wakeUp = changeWakeUp
    @State private var cofferAmt = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var changeWakeUp: Date{
        var component = DateComponents()
        component.hour = 7
        component.minute = 0
        return Calendar.current.date(from: component) ?? Date.now
    }
    var body: some View {
        NavigationView{
            
            Form{
                
                Section{
                    Text("When did you want to wake up?")
                        .font(.headline)
                    DatePicker("Please enter time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section(header:  Text("Desired amount of sleep") .fontWeight(.black) ){
                    
                    Stepper("\(sleepAmt.formatted()) hours", value: $sleepAmt,in: 4...24,step: 0.25)
                }
                Section(header:  Text("Daily Coffee Intake") .fontWeight(.black) ){
                    
                    
                    Picker("No. of Cups", selection: $cofferAmt){
                        ForEach(1..<50){
                            Text("\($0)")
                        }
                    }
                }
                
                Section(header: Text("Recommended Bed Time").fontDesign(.monospaced).fontWeight(.black).font(.title)){
                    Text("\(calculateBedTime())")
                }
                
            }
            .navigationTitle("BetterRest")
           
            
            
        }
        
    }
    func calculateBedTime() -> String{
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let component = Calendar.current.dateComponents([.hour,.minute], from: wakeUp)
            let hour = (component.hour ?? 0) * 60 * 60
            let minute = (component.minute ?? 0)*60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmt, coffee: Double(cofferAmt))
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            return "Sorry! there was a problem calculating your bed time"
            
        }
//        showingAlert = true
//
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
