//
//  Util.swift
//  park
//
//  Created by Ethan Brooks on 5/1/16.
//  Copyright © 2016 Ethan Brooks. All rights reserved.
//

import Foundation

func approxLessThan(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    return right - left > epsilon
}

func almostEqual(left: Double, _ right: Double, _ epsilon: Double) -> Bool {
    let absdiff = abs(left - right)
    return absdiff < epsilon
}
