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
        
        let readings = formattedData.map { $0.reading }
        var minReading = readings.min()
        var maxReading = readings.max()
        var meanReading = readings.reduce(0, +) / Double(readings.count)
        
        return UIHostingController(coder: coder, rootView: ContentView(average: meanReading, data: formattedData))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chart Controller Connected")
    }
}

struct ContentView: View {
    var average: Double
    var data: [FormattedTest]
    
    var body: some View {
        VStack {
            if data.isEmpty {
                Text("No data available")
            } else {
                Chart {
                    ForEach(data) { dataPoint in
                        LineMark(x: .value("Date", dataPoint.date),
                                 y: .value("INR", dataPoint.reading))
                    }
                    
                    RuleMark(y: .value("MinTR", 2))
                        .foregroundStyle(.red)
                        .annotation(position: .bottom,
                                    alignment: .bottomLeading) {
                            Text("Therapeutic Range Min: 2")
                        }
                    
                    RuleMark(y: .value("MaxTR", 3.5))
                        .foregroundStyle(.red)
                        .annotation(position: .top,
                                    alignment: .bottomLeading) {
                            Text("Therapeutic Range Max: 3.5")
                        }
                    
                    RuleMark(y: .value("Average", average))
                        .foregroundStyle(.green)
                        .lineStyle(StrokeStyle(lineWidth: 6, dash: [14,7]))
                        .annotation(position: .top,
                                    alignment: .bottomLeading) {
                            Text("Avg: " + String(format: "%.1f", average))
                                .fontWeight(.bold)
                        }
                }
                .chartYScale(domain: 1...4)
                .padding()
            }
        }
    }
}
