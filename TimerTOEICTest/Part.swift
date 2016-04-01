//
//  Part.swift
//  TimerTOEICTest
//
//  Created by Tuan-Vi Phan on 4/1/16.
//  Copyright © 2016 Tuan-Vi Phan. All rights reserved.
//

import UIKit

class Part {
    let toeicPart: String
    let toeicMin: Double
    var checked: Bool
    
    required init(Part: String, Min: Double) {
        self.toeicPart = Part
        self.toeicMin = Min
        self.checked = false
    }
    
    func toggleChecked() {
        checked = !checked
    }
}