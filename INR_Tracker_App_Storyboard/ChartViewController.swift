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
        let minReading = formattedData[minINRidx].reading
        let maxINRidx = formattedData.firstIndex { $0.reading == readings.max() } ?? 0
        let maxReading = formattedData[maxINRidx].reading
        
        let ninetyDays = filterTestsLastNDays(days: 90, tests: formattedData)
        let oneYear = filterTestsLastNDays(days: 365, tests: formattedData)
        
        return UIHostingController(coder: coder, rootView: ContentView(
            data: formattedData,
            ninetyDaysData: ninetyDays,
            oneYearData: oneYear,
            allDataInit: formattedData,
            allDataMin: minReading,
            allDataMax: maxReading)
        )
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
    
    @State private var trToggle = false
    @State private var avgToggle = false
    @State private var minmaxToggle = false
    @State private var currentTab = "All Time"
    @State var currentActiveItem: FormattedTest?
    
    let allDataInit: [FormattedTest]
    let allDataMin: Double
    let allDataMax: Double
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        
        NavigationStack{
            
            if verticalSizeClass == .regular {
                
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
                .onChange(of: currentTab) { selection in
                    handleChange(selection: selection)
                    animateGraph(fromChange: true)
                }
                
                HStack{
                    Spacer()
                    
                    Toggle(isOn: $trToggle) {
                        Text("Therapeutic Range")
                    }
                    
                }.padding()
                
                HStack{
                    Spacer()
                    
                    Toggle(isOn: $avgToggle) {
                        Text("Average")
                    }
                    
                }.padding()
                
                HStack{
                    Spacer()
                    
                    Toggle(isOn: $minmaxToggle) {
                        Text("Min/Max")
                    }
                    
                }.padding()
                
            } else {
                
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
                .onChange(of: currentTab) { selection in
                    handleChange(selection: selection)
                    animateGraph(fromChange: true)
                }
                
            }
        }
    }
    
    @ViewBuilder
    func AnimatedChart() -> some View {
        
        let readings = data.map { $0.reading }
        let average = readings.reduce(0, +) / Double(readings.count)
        let min = data.firstIndex { $0.reading == readings.min() } ?? 0
        let max = data.firstIndex { $0.reading == readings.max() } ?? 0
        
        let curColor = Color(hue: 0.6, saturation: 0.81, brightness: 0.76)
        let curGradient = LinearGradient(
             gradient: Gradient (
                 colors: [
                    curColor.opacity(0.5),
                    curColor.opacity(0.2),
                    curColor.opacity(0.05),
                ]
            ),
            startPoint: .top,
             endPoint: .bottom
        )
        
        Chart {
            ForEach(data) { dataPoint in
                LineMark(x: .value("Date", dataPoint.date),
                         y: .value("INR", dataPoint.animate ? dataPoint.reading : average)
                )
                .interpolationMethod(.catmullRom)
                .symbol(.circle)
                
                AreaMark(x: .value("Date", dataPoint.date),
                         yStart: .value("INR", dataPoint.animate ? allDataMin : allDataMin),
                         yEnd: .value("INR", dataPoint.animate ? dataPoint.reading : average)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(curGradient)
                
                if let currentActiveItem, currentActiveItem.id == dataPoint.id {
                    RuleMark(x: .value("Date", currentActiveItem.date))
                        .lineStyle(.init(lineWidth: 2, dash: [2], dashPhase: 5))
                        .annotation(position: .top){
                            VStack(alignment: .leading, spacing: 6){
                                Text("INR")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(String(currentActiveItem.reading))
                                    .font(.title3.bold())
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background{
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                        }
                }
    
            }
            
            if minmaxToggle {
                PointMark(x: .value("Date", data[min].date),
                          y: .value("INR", data[min].reading))
                .foregroundStyle(.red)
                .annotation(position: .bottom,
                            alignment: .center) {
                    Text("" + String(data[min].reading))
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 2)))
                        }
                }
                
                PointMark(x: .value("Date", data[max].date),
                          y: .value("INR", data[max].reading))
                .foregroundStyle(.red)
                .annotation(position: .top,
                            alignment: .center) {
                    Text("" + String(data[max].reading))
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.white.shadow(.drop(radius: 2)))
                        }
                }
            }
            
            if trToggle {
                RuleMark(y: .value("MinTR", 2))
                    .foregroundStyle(.red)
                    .annotation(position: .bottom,
                                alignment: .bottomLeading) {
                        Text("TR Min: 2.0")
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                    }
                
                RuleMark(y: .value("MaxTR", 3.5))
                    .foregroundStyle(.red)
                    .annotation(position: .top,
                                alignment: .bottomLeading) {
                        Text("TR Max: 3.5")
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                    }
            }
            
            if avgToggle {
                RuleMark(y: .value("Average", average))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 6, dash: [14,7]))
                    .annotation(position: .automatic,
                                alignment: .bottomLeading) {
                        Text("Avg: " + String(format: "%.1f", average))
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.white.shadow(.drop(radius: 2)))
                            }
                    }
            }
            
        }
        .chartYScale(domain: allDataMin - 0.2 ... allDataMax + 0.2)
        .chartOverlay(content: {proxy in
            GeometryReader{innerProxy in
                Rectangle()
                    .fill(.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged{ value in
                                let location = value.location
                                if let touchDate: Date = proxy.value(atX: location.x){
                                    
                                    let calendar = Calendar.current
                                    let day = calendar.component(.day, from: touchDate)
                                    let month = calendar.component(.month, from: touchDate)
                                    let year = calendar.component(.year, from: touchDate)
                                    
                                    if let currentItem = data.first(where: { item in
                                        calendar.component(.day, from: item.date) == day &&
                                        calendar.component(.month, from: item.date) == month &&
                                        calendar.component(.year, from: item.date) == year
                                    }){
                                        self.currentActiveItem = currentItem
                                    }
                                }
                            }.onEnded{value in
                                self.currentActiveItem = nil
                            }
                    )
            }
        })
        .onAppear(){
           animateGraph()
       }
    }
    
    func animateGraph(fromChange: Bool = false){
        for (index,_) in data.enumerated(){
            DispatchQueue.main.asyncAfter(deadline: .now()){
                withAnimation(fromChange ? .easeInOut(duration: 0.8) :
                        .interactiveSpring(response: 0.8, dampingFraction: 0.8, blendDuration: 0.8)){
                    data[index].animate = true
                }
            }
        }
    }
    
    func handleChange(selection: String){
        if selection == "90 Days" {
            data = ninetyDaysData
        } else if selection == "1 Year" {
            data = oneYearData
        } else {
            data = allDataInit
        }
    }
}
