//#-hidden-code
import UIKit
//#-end-hidden-code
//#-hidden-code
import UIKit
import PlaygroundSupport

let canvasView = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 512))
canvasView.backgroundColor = .white
canvasView.layer.borderColor = UIColor.lightGray.cgColor
canvasView.layer.borderWidth = 1
PlaygroundPage.current.liveView = canvasView
//#-end-hidden-code

//#-editable-code
let frame = CGRect(x: 0, y: 0, width: 100, height: 100)

let square = UIView(frame: frame)
square.backgroundColor = .orange

UIView.animate(withDuration: 2,
                      delay: 1,
                    options: .curveLinear,
                animations: {
                    
    square.frame = CGRect(x: 412, y: 0, width: 100, height: 100)
                    
}, completion: nil)

//#-end-editable-code

//#-hidden-code
canvasView.addSubview(square)
//#-end-hidden-code