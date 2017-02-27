//
//  Helpers.swift
//  GRobot
//
//  Created by Cloud Dai on 27/2/2017.
//  Copyright © 2017 Cloud Dai. All rights reserved.
//

import Foundation


func random(_ upper: Int) -> Int
{
  return Int(arc4random_uniform(UInt32(upper)))
}

func powInt(_ lhs: Int, _ rhs: Int) -> Int
{
  return Int(powf(Float(lhs), Float(rhs)))
}
