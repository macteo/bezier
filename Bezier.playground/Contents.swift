//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

let bezierController = BezierController()
let interpolationController = InterpolationController()

let frame = CGRect(x: 0, y: 0, width: 500, height: 520)

bezierController.view.frame = frame
interpolationController.view.frame = frame

PlaygroundPage.current.liveView = interpolationController.view
PlaygroundPage.current.needsIndefiniteExecution = true
