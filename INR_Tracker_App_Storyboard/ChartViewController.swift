//
//  ChartViewController.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-26.
//

import UIKit
import SwiftUI
import Charts

struct FormattedTest: Identifiable {
    var date: Date
    var reading: Double
    var animate: Bool = false
    
    var id: Date {return date}
}

class ChartViewController: UIViewController {
    
    var data = [Test]()
    var formattedData = [FormattedTest]()
    
    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        formattedData = data.compactMap { test in
            if let date = dateFormatter.date(from: test.date),
               let reading = Double(test.reading) {
                return FormattedTest(date: date, reading: reading)
            }
            return nil
        }
                
        let readings = formattedData.map { $0.reading }
        let minINRidx = formattedData.firstIndex { $0.reading == readings.min() } ?? 0
        let maxINRidx = formattedData.firstIndex { $0.reading == readings.max() } ?? 0
        let avgINR = readings.reduce(0, +) / Double(readings.count)
        
        let ninetyDays = filterTestsLastNDays(days: 90, tests: formattedData)
        let oneYear = filterTestsLastNDays(days: 365, tests: formattedData)
        
        return UIHostingController(coder: coder, rootView: ContentView(
            data: formattedData,
            ninetyDaysData: ninetyDays,
            oneYearData: oneYear,
            average: avgINR,
            min: minINRidx,
            max: maxINRidx))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chart Controller Connected")
    }
    
    func filterTestsLastNDays(days: Int, tests: [FormattedTest]) -> [FormattedTest] {
        let currentDate = Date()
        let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -(days), to: currentDate)!
        let filteredTests = tests.filter { $0.date >= sixtyDaysAgo && $0.date <= currentDate }
        return filteredTests
    }
}

struct ContentView: View {
    
    @State var data: [FormattedTest]
    @State var ninetyDaysData: [FormattedTest]
    @State var oneYearData: [FormattedTest]
    @State var average: Double
    @State var min: Int
    @State var max: Int
    
    
    @State private var trToggle = false
    @State private var avgToggle = false
    @State private var minmaxToggle = false
    @State private var currentTab = "All Time"
    
    var body: some View {
        
        NavigationStack{
            
            VStack{
                
                VStack(alignment: .leading, spacing: 12){
                    HStack{
                        Picker("", selection: $currentTab) {
                            Text("All Time").tag("All Time")
                            Text("1 Year").tag("1 Year")
                            Text("90 Days").tag("90 Days")
                        }
                        .pickerStyle(.segmented)
                        .padding()
                    }
                    AnimatedChart()
                }
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.shadow(.drop(radius: 2)))
                }
            }
            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, maxHeight: .infinity, alignment: .top)
            .padding()
//            .navigationTitle("Chart")
            .onChange(of: currentTab) { selection in
                data = data
//                handleChange(selection: selection)
                animateGraph(fromChange: true)
            }
            
            HStack{
                Spacer()

                Toggle(isOn: $trToggle) {
                    Text("Therapeutic Range")
                }

            }.padding() // TR Toggle

            HStack{
                Spacer()

                Toggle(isOn: $avgToggle) {
                    Text("Average")
                }

            }.padding() // Avg Toggle

            HStack{
                Spacer()

                Toggle(isOn: $minmaxToggle) {
                    Text("Min/Max")
                }

            }.padding() // Min Max Toggle
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        Chart {
            ForEach(data) { dataPoint in
                LineMark(x: .value("Date", dataPoint.date),
                         y: .value("INR", dataPoint.reading))
            }
            
            if minmaxToggle {
                PointMark(x: .value("Date", data[min].date),
                          y: .value("INR", data[min].reading))
                .foregroundStyle(.red)
                .annotation(position: .bottom,
                            alignment: .center) {
                    Text("" + String(data[min].reading))
                        .fontWeight(.bold)
                        .background(Rectangle()
                            .foregroundColor(.white))
                }
                
                PointMark(x: .value("Date", data[max].date),
                          y: .value("INR", data[max].reading))
                .foregroundStyle(.red)
                .annotation(position: .top,
                            alignment: .center) {
                    Text("" + String(data[max].reading))
                        .fontWeight(.bold)
                        .background(Rectangle()
                            .foregroundColor(.white))
                }
            }
            
            if trToggle {
                RuleMark(y: .value("MinTR", 2))
                    .foregroundStyle(.red)
                    .annotation(position: .bottom,
                                alignment: .bottomLeading) {
                        Text("TR Min: 2.0")
                            .fontWeight(.bold)
                            .background(Rectangle()
                                .foregroundColor(.white))
                    }
                
                RuleMark(y: .value("MaxTR", 3.5))
                    .foregroundStyle(.red)
                    .annotation(position: .top,
                                alignment: .bottomLeading) {
                        Text("TR Max: 3.5")
                            .fontWeight(.bold)
                            .background(Rectangle()
                                .foregroundColor(.white))
                    }
            }
            
            if avgToggle {
                RuleMark(y: .value("Average", average))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 6, dash: [14,7]))
                    .annotation(position: .top,
                                alignment: .bottomLeading) {
                        Text("Avg: " + String(format: "%.1f", average))
                            .fontWeight(.bold)
                            .background(Rectangle()
                                .foregroundColor(.white))
                    }
            }
            
        }
        .chartYScale(domain: (data[min].reading - 0.1)...(data[max].reading + 0.1))
        .padding()
        .onAppear(){
           animateGraph()
       }
    }
    
    func animateGraph(fromChange: Bool = false){
        for (index,_) in data.enumerated(){
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * (fromChange ? 0.03 : 0.05)){
                withAnimation(fromChange ? .easeInOut(duration: 0.8) :
                        .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                    data[index].animate = true
                }
            }
        }
    }
    
    func handleChange(selection: String){
        if selection != "90 Days" {
            for (index,_) in data.enumerated(){
                data[index].reading = .random(in: 2...3)
            }
        }
    }
}
