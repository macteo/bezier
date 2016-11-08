import UIKit

public class ConstructionView : UIView {
    let canvasSize : CGFloat = 300
    var startPoint : CGPoint!
    var endPoint : CGPoint!
    var controlPoint1 : CGPoint!
    var controlPoint2 : CGPoint!
    let canvas = CALayer()
    let joinBezier = CAShapeLayer()
    let leftHandle = CAShapeLayer()
    let rightHandle = CAShapeLayer()
    let lefArm = CAShapeLayer()
    let rightArm = CAShapeLayer()
    let armsConnection = CAShapeLayer()
    let handleSize : CGFloat = 8
    let animationDuration : TimeInterval = 1
    let padding : CGFloat = 100
    
    let leftArmBall = UIView()
    let rightArmBall = UIView()
    let armsConnectionBall = UIView()
    
    var startAnimationButton : UIButton!
    var resetAnimationButton : UIButton!
    
    let firstBridge = CAShapeLayer()
    let secondBridge = CAShapeLayer()
    let thirdBridge = CAShapeLayer()
    
    let firstBridgeBall = UIView()
    let secondBridgeBall = UIView()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        
        startPoint = CGPoint(x: 0, y: canvasSize)
        endPoint = CGPoint(x: canvasSize, y: canvasSize / 2)
        
        controlPoint1 = CGPoint(x: 0, y: canvasSize / 2)
        controlPoint2 = CGPoint(x: canvasSize / 2, y: canvasSize / 3)
        
        canvas.addSublayer(armsConnection)
        canvas.addSublayer(lefArm)
        canvas.addSublayer(rightArm)
        canvas.addSublayer(joinBezier)
        canvas.addSublayer(leftHandle)
        canvas.addSublayer(rightHandle)
        
        canvas.frame = CGRect(x: padding, y: padding, width: canvasSize, height: canvasSize)
        canvas.borderColor = UIColor.white.cgColor
        canvas.borderWidth = 0.0
        layer.addSublayer(canvas)
        
        let pointSize : CGFloat = 8
        let originPoint = CAShapeLayer()
        originPoint.path = UIBezierPath(ovalIn: CGRect(x: startPoint.x, y: startPoint.y, width: pointSize, height: pointSize)).cgPath
        originPoint.frame = CGRect(x: -pointSize / 2, y: -pointSize / 2, width: pointSize, height: pointSize)
        originPoint.fillColor = UIColor.blue.cgColor
        canvas.addSublayer(originPoint)
        
        let finalPoint = CAShapeLayer()
        finalPoint.path = UIBezierPath(ovalIn: CGRect(x: endPoint.x, y: endPoint.y, width: pointSize, height: pointSize)).cgPath
        finalPoint.frame = CGRect(x: -pointSize / 2, y: -pointSize / 2, width: pointSize, height: pointSize)
        finalPoint.fillColor = UIColor.blue.cgColor
        canvas.addSublayer(finalPoint)
        
        let leftHandleView = UIView(frame: CGRect(x: controlPoint1.x + padding - 20, y: controlPoint1.y + padding - 20, width: 40, height: 40))
        leftHandleView.backgroundColor = .clear
        leftHandleView.tag = 1
        
        addSubview(leftHandleView)
        let leftHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        leftHandleView.addGestureRecognizer(leftHandlePan)
        
        let rightHandleView = UIView(frame: CGRect(x: controlPoint2.x + padding - 20, y: controlPoint2.y + padding - 20, width: 40, height: 40))
        rightHandleView.backgroundColor = .clear
        rightHandleView.tag = 2
        addSubview(rightHandleView)
        let rightHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        rightHandleView.addGestureRecognizer(rightHandlePan)
        
        startAnimationButton = UIButton(frame: CGRect(x: padding, y: canvasSize + padding, width: 60, height: 44))
        startAnimationButton.setTitleColor(.black, for: .normal)
        startAnimationButton.setTitle("Play", for: .normal)
        startAnimationButton.addTarget(self, action: #selector(animate), for: .touchUpInside)
        addSubview(startAnimationButton)
        
        resetAnimationButton = UIButton(frame: CGRect(x: padding * 2 + 60, y: canvasSize + padding, width: 60, height: 44))
        resetAnimationButton.setTitleColor(.black, for: .normal)
        resetAnimationButton.setTitle("Reset", for: .normal)
        resetAnimationButton.addTarget(self, action: #selector(resetAnimation), for: .touchUpInside)
        addSubview(resetAnimationButton)
        
        canvas.addSublayer(firstBridge)
        canvas.addSublayer(secondBridge)
        canvas.addSublayer(thirdBridge)
        
        drawLayers()
    }
    
    func drawLayers() {
        
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        bezier.addCurve(to: CGPoint(x: endPoint.x, y:endPoint.y), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        joinBezier.frame = canvas.bounds
        joinBezier.path = bezier.cgPath
        joinBezier.lineWidth = 2
        joinBezier.fillColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
        joinBezier.strokeColor = UIColor.clear.cgColor
        
        leftHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint1.x, y: controlPoint1.y, width: handleSize, height: handleSize)).cgPath
        leftHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        leftHandle.lineWidth = 2
        leftHandle.fillColor = UIColor.white.cgColor
        leftHandle.strokeColor = UIColor.blue.cgColor
        
        rightHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint2.x, y: controlPoint2.y, width: handleSize, height: handleSize)).cgPath
        rightHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        rightHandle.lineWidth = 2
        rightHandle.fillColor = UIColor.white.cgColor
        rightHandle.strokeColor = UIColor.blue.cgColor
        
        let leftArmPath = UIBezierPath()
        leftArmPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        leftArmPath.addLine(to: controlPoint1)
        
        lefArm.frame = canvas.bounds
        lefArm.path = leftArmPath.cgPath
        lefArm.lineWidth = 2
        lefArm.fillColor = UIColor.clear.cgColor
        lefArm.strokeColor = UIColor.blue.cgColor
        
        let rightArmPath = UIBezierPath()
        rightArmPath.move(to: CGPoint(x: endPoint.x, y: endPoint.y))
        rightArmPath.addLine(to: controlPoint2)
        
        rightArm.frame = canvas.bounds
        rightArm.path = rightArmPath.cgPath
        rightArm.lineWidth = 2
        rightArm.fillColor = UIColor.clear.cgColor
        rightArm.strokeColor = UIColor.blue.cgColor
        
        let armsConnectionPath = UIBezierPath()
        armsConnectionPath.move(to: CGPoint(x: controlPoint1.x, y: controlPoint1.y))
        armsConnectionPath.addLine(to: controlPoint2)
        
        armsConnection.lineDashPattern = [3, 3, 3, 3]
        armsConnection.frame = canvas.bounds
        armsConnection.path = armsConnectionPath.cgPath
        armsConnection.lineWidth = 1
        armsConnection.fillColor = UIColor.clear.cgColor
        armsConnection.strokeColor = UIColor.darkGray.cgColor
        
        let armBallSize : CGFloat = 6
        let armBallColor = UIColor.green
        
        leftArmBall.frame = CGRect(x: padding + startPoint.x - armBallSize / 2, y: padding + startPoint.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        leftArmBall.layer.cornerRadius = armBallSize / 2
        leftArmBall.backgroundColor = armBallColor
        addSubview(leftArmBall)
        
        armsConnectionBall.frame = CGRect(x: padding + controlPoint1.x - armBallSize / 2, y: padding + controlPoint1.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        armsConnectionBall.layer.cornerRadius = armBallSize / 2
        armsConnectionBall.backgroundColor = armBallColor
        addSubview(armsConnectionBall)
        
        rightArmBall.frame = CGRect(x: padding + controlPoint2.x - armBallSize / 2, y: padding + controlPoint2.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        rightArmBall.layer.cornerRadius = armBallSize / 2
        rightArmBall.backgroundColor = armBallColor
        addSubview(rightArmBall)
        
        firstBridgeBall.frame = CGRect(x: padding + startPoint.x - armBallSize / 2, y: padding + startPoint.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        firstBridgeBall.layer.cornerRadius = armBallSize / 2
        firstBridgeBall.backgroundColor = .clear
        addSubview(firstBridgeBall)
        
        secondBridgeBall.frame = CGRect(x: padding + controlPoint1.x - armBallSize / 2, y: padding + controlPoint1.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        secondBridgeBall.layer.cornerRadius = armBallSize / 2
        secondBridgeBall.backgroundColor = .clear
        addSubview(secondBridgeBall)
        
        let firstBridgePath = UIBezierPath()
        firstBridgePath.move(to: startPoint)
        firstBridgePath.addLine(to: controlPoint1)
        
        firstBridge.frame = canvas.bounds
        firstBridge.path = firstBridgePath.cgPath
        firstBridge.lineWidth = 2
        firstBridge.fillColor = UIColor.clear.cgColor
        firstBridge.strokeColor = UIColor.clear.cgColor
        
        let secondBridgePath = UIBezierPath()
        secondBridgePath.move(to: controlPoint1)
        secondBridgePath.addLine(to: controlPoint2)
        
        secondBridge.frame = canvas.bounds
        secondBridge.path = secondBridgePath.cgPath
        secondBridge.lineWidth = 2
        secondBridge.fillColor = UIColor.clear.cgColor
        secondBridge.strokeColor = UIColor.clear.cgColor
        
        let thirdBridgePath = UIBezierPath()
        thirdBridgePath.move(to: controlPoint1)
        thirdBridgePath.addLine(to: controlPoint2)
        thirdBridge.frame = canvas.bounds
        thirdBridge.path = thirdBridgePath.cgPath
        thirdBridge.lineWidth = 2
        thirdBridge.fillColor = UIColor.clear.cgColor
        thirdBridge.strokeColor = UIColor.clear.cgColor
    }
    
    func resetAnimation() {
        
        let firstBridgePath = UIBezierPath()
        firstBridgePath.move(to: startPoint)
        firstBridgePath.addLine(to: controlPoint1)
        firstBridge.path = firstBridgePath.cgPath
        firstBridge.strokeColor = UIColor.clear.cgColor
        
        let secondBridgePath = UIBezierPath()
        secondBridgePath.move(to: controlPoint1)
        secondBridgePath.addLine(to: controlPoint2)
        secondBridge.path = secondBridgePath.cgPath
        secondBridge.strokeColor = UIColor.clear.cgColor
        
        leftArmBall.center = padded(startPoint)
        armsConnectionBall.center = padded(controlPoint1)
        rightArmBall.center = padded(controlPoint2)
        
        firstBridgeBall.center = leftArmBall.center
        secondBridgeBall.center = armsConnectionBall.center
    }
    
    func animate() {
        resetAnimation()
        resetAnimationButton.isEnabled = false
        startAnimationButton.isEnabled = false
        
        firstBridge.strokeColor = UIColor.green.cgColor
        secondBridge.strokeColor = UIColor.green.cgColor
        thirdBridge.strokeColor = UIColor.green.cgColor
        firstBridgeBall.backgroundColor = .red
        secondBridgeBall.backgroundColor = .red
        
        let animatorLinear = UIViewPropertyAnimator(duration: self.animationDuration, curve: .linear, animations: {
            self.leftArmBall.center = self.padded(self.controlPoint1)
            self.armsConnectionBall.center = self.padded(self.controlPoint2)
            self.rightArmBall.center = self.padded(self.endPoint)
        })
        
        let firstBridgePath = UIBezierPath()
        firstBridgePath.move(to: controlPoint1)
        firstBridgePath.addLine(to: controlPoint2)
        
        let secondBridgePath = UIBezierPath()
        secondBridgePath.move(to: controlPoint2)
        secondBridgePath.addLine(to: endPoint)
        
        let thirdBridgePath = UIBezierPath()
        thirdBridgePath.move(to: padded(startPoint))
        thirdBridgePath.addQuadCurve(to: padded(controlPoint2), controlPoint: padded(self.controlPoint1))
        
        let fourthBridgePath = UIBezierPath()
        fourthBridgePath.move(to: padded(controlPoint1))
        fourthBridgePath.addQuadCurve(to: padded(endPoint), controlPoint: padded(controlPoint2))
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update(displayLink:)))
        displayLink.preferredFramesPerSecond = 60
        
        // let displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        // displayLink.add(to: RunLoop.main, forMode: .UITrackingRunLoopMode)
        // displayLink.add(to: RunLoop.main, forMode: .commonModes)
        
        animatorLinear.addCompletion {
            _ in
            self.resetAnimationButton.isEnabled = true
            self.startAnimationButton.isEnabled = true
            self.firstBridge.path = firstBridgePath.cgPath
            self.secondBridge.path = secondBridgePath.cgPath
            
            self.firstBridge.removeAllAnimations()
            self.secondBridge.removeAllAnimations()
            displayLink.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            // displayLink.remove(from: RunLoop.main, forMode: .UITrackingRunLoopMode)
            // displayLink.invalidate()
            // displayLink.remove(from: RunLoop.main, forMode: .commonModes)
        }
        animatorLinear.startAnimation()
        
        let firstAnimation = CABasicAnimation(keyPath: "path")
        firstAnimation.toValue = firstBridgePath.cgPath
        firstAnimation.duration = animationDuration
        firstAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        firstAnimation.fillMode = kCAFillModeBoth
        firstAnimation.isRemovedOnCompletion = false
        firstBridge.add(firstAnimation, forKey:firstAnimation.keyPath)
        
        let secondAnimation = CABasicAnimation(keyPath: "path")
        secondAnimation.toValue = secondBridgePath.cgPath
        secondAnimation.duration = animationDuration
        secondAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        secondAnimation.fillMode = kCAFillModeBoth
        secondAnimation.isRemovedOnCompletion = false
        secondBridge.add(secondAnimation, forKey:secondAnimation.keyPath)
        
        let thirdAnimation = CAKeyframeAnimation(keyPath: "position")
        thirdAnimation.path = thirdBridgePath.cgPath
        thirdAnimation.duration = animationDuration
        thirdAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        thirdAnimation.fillMode = kCAFillModeBoth
        thirdAnimation.isRemovedOnCompletion = false
        firstBridgeBall.layer.add(thirdAnimation, forKey:thirdAnimation.keyPath)
        
        let fourthAnimation = CAKeyframeAnimation(keyPath: "position")
        fourthAnimation.path = fourthBridgePath.cgPath
        fourthAnimation.duration = animationDuration
        fourthAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        fourthAnimation.fillMode = kCAFillModeBoth
        fourthAnimation.isRemovedOnCompletion = false
        secondBridgeBall.layer.add(fourthAnimation, forKey:fourthAnimation.keyPath)
    }
    
    func padded(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + padding, y: point.y + padding)
    }
    
    func unpadded(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - padding, y: point.y - padding)
    }
    
    @objc func update(displayLink: CADisplayLink) {
        print(displayLink.timestamp)
        /*
        let first = unpadded(firstBridgeBall.layer.presentation()!.position)
        let second = unpadded(secondBridgeBall.layer.presentation()!.position)
        
        let thirdBridgePath = UIBezierPath()
        thirdBridgePath.move(to: first)
        thirdBridgePath.addLine(to: second)
        thirdBridge.path = thirdBridgePath.cgPath */
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch (gesture.state) {
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            var x = gesture.view!.center.x + translation.x
            var y = gesture.view!.center.y + translation.y
            if x < 0 { x = 0 }
            if x > canvasSize + 2 * padding { x = canvasSize + 2 * padding }
            if y < 0 { y = 0 }
            if y > bounds.size.height { y = bounds.size.height }
            gesture.view!.center =  CGPoint(x: x, y: y)
            gesture.setTranslation(CGPoint(x:0, y:0), in: gesture.view)
            
            var point = controlPoint1!
            if gesture.view?.tag == 2 {
                point = controlPoint2!
            }
            x = point.x + translation.x
            y = point.y + translation.y
            
            if x < -padding { x = -padding }
            if x > canvasSize + padding { x = canvasSize + padding }
            if y < -padding { y = -padding }
            if y > bounds.size.height - padding { y = bounds.size.height - padding }
            point = CGPoint(x: x, y: y)
            if gesture.view?.tag == 1 {
                controlPoint1 = point
            } else {
                controlPoint2 = point
            }
            
            drawLayers()
        default:
            break
        }
    }
}
