//
//  ChartViewController.swift
//  INR_Tracker_App_Storyboard
//
//  Created by Chris Brunet on 2023-12-26.
//

import UIKit
import SwiftUI
import Charts

class ChartViewController: UIViewController {
    
    var data = [Test]()
    
    @IBSegueAction func embedSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: ContentView(data: data))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Chart Controller Connected")
    }
}

struct ContentView: View {
    
    var data: [Test]
    
    var body: some View {
        Chart {
            ForEach(data) { dataPoint in
                LineMark(x: .value("Date", dataPoint.date),
                         y: .value("INR", Double(dataPoint.reading)!))
            }
            
            RuleMark(y: .value("MinTR", 2))
                .foregroundStyle(.red)
            
            RuleMark(y: .value("MaxTR", 3.5))
                .foregroundStyle(.red)
            
        }
        .chartYScale(domain: 1...4)
        .padding()
    }
}
