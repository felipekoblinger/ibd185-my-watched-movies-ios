//
//  DigitValueFormatter.swift
//  MyWatchedMovies
//
//  Created by Felipe Koblinger on 6/19/18.
//  Copyright © 2018 Felipe Koblinger. All rights reserved.
//

import Foundation
import Charts

class DigitValueFormatter : NSObject, IValueFormatter {
    
    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        let valueWithoutDecimalPart = String(format: "%.0f", value)
        return "\(valueWithoutDecimalPart)"
    }
}
