//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let timingParameters = UICubicTimingParameters(controlPoint1: CGPoint(x:0, y:0), controlPoint2: CGPoint(x:1, y:1))

var rootVC = BezierController()

rootVC.view.frame = CGRect(x: 0, y: 0, width: 500, height: 520)
PlaygroundPage.current.liveView = rootVC.view
PlaygroundPage.current.needsIndefiniteExecution = true
