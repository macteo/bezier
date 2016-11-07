//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

/*
let bezierController = BezierController()
let interpolationController = InterpolationController()
*/
let constructionController = ConstructionController()

let frame = CGRect(x: 0, y: 0, width: 500, height: 500)

/*
bezierController.view.frame = frame
interpolationController.view.frame = frame
 */

constructionController.view.frame = frame

PlaygroundPage.current.liveView = constructionController.view
PlaygroundPage.current.needsIndefiniteExecution = true

