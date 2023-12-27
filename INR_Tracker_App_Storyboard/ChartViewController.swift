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
        
//        print(formattedData)
        
        let readings = formattedData.map { $0.reading }
        let minINRidx = formattedData.firstIndex { $0.reading == readings.min() } ?? 0
        let maxINRidx = formattedData.firstIndex { $0.reading == readings.max() } ?? 0
        let avgINR = readings.reduce(0, +) / Double(readings.count)
        
        return UIHostingController(coder: coder, rootView: ContentView(
            data: formattedData,
            average: avgINR,
            min: minINRidx,
            max: maxINRidx))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chart Controller Connected")
    }
}

struct ContentView: View {
    var data: [FormattedTest]
    var average: Double
    var min: Int
    var max: Int
    
    @State private var trToggle = false
    @State private var avgToggle = false
    @State private var minmaxToggle = false
    
    var body: some View {
        VStack{
            
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
            
        }
    }
}
