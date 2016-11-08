//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

// let controller = BezierController()
let controller = DrawController()
 // let controller = InterpolationController()

let frame = CGRect(x: 0, y: 0, width: 500, height: 500)
controller.view.frame = frame

PlaygroundPage.current.liveView = controller.view
PlaygroundPage.current.needsIndefiniteExecution = true