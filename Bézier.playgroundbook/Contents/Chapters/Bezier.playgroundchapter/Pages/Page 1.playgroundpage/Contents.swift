//#-hidden-code
import UIKit
import CoreGraphics
//#-end-hidden-code
/*
let bezierController = BezierController()
let interpolationController = InterpolationController()
*/
let frame = CGRect(x: 0, y: 0, width: 500, height: 500)
let constructionView = ConstructionView(frame: frame)

/*
bezierController.view.frame = frame
interpolationController.view.frame = frame
 */
PlaygroundPage.current.liveView = constructionView
PlaygroundPage.current.needsIndefiniteExecution = true