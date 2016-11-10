import UIKit

enum GenesisStep {
    case first
    case second
    case third
    case fourth
    case fifth
    case sixth
    case seventh
    case eight
    
    var string : String {
        switch self {
        case .first:
            return "1"
        case .second:
            return "2"
        case .third:
            return "3"
        case .fourth:
            return "4"
        case .fifth:
            return "5"
        case .sixth:
            return "6"
        case .seventh:
            return "7"
        case .eight:
            return "8"
        }
    }
}

enum GenesisElement {
    case point
    case controlPoint
    case joinLine
    case handle
    case bezier
    case bridge
    case bridgePoint
    case bridgeTangentPoint
    case tangent
    case tangentPoint
}

enum ColorType {
    case stroke
    case fill
}

let purple = "#5D68E6".color
let black = UIColor.black
let gray = "#F9F9F9".color
let lighterGray = UIColor.lightGray.withAlphaComponent(0.2)
let green = "#98C949".color
let fuxia = "#D34BC8".color

public class GenesisController : UIViewController {
    var step = GenesisStep.first
    
    let steps : [GenesisStep] = [.first, .second, .third, .fourth, .fifth, .sixth, .seventh, .eight]
    
    let canvasSize : CGFloat = 300
    var startPoint : CGPoint!
    var endPoint : CGPoint!
    var controlPoint1 : CGPoint!
    var controlPoint2 : CGPoint!
    let canvas = CALayer()
    let joinBezier = CAShapeLayer()
    let leftHandle = CAShapeLayer()
    let rightHandle = CAShapeLayer()
    let leftArm = CAShapeLayer()
    let rightArm = CAShapeLayer()
    let armsConnection = CAShapeLayer()
    let handleSize : CGFloat = 8
    let animationDuration : TimeInterval = 3
    let padding : CGFloat = 100
    
    let leftArmBall = UIView()
    let rightArmBall = UIView()
    let armsConnectionBall = UIView()
    
    var startAnimationButton : UIButton!
    var resetAnimationButton : UIButton!
    
    var nextButton : UIButton!
    var previousButton : UIButton!
    
    let firstBridge = CAShapeLayer()
    let secondBridge = CAShapeLayer()
    let thirdBridge = CAShapeLayer()
    
    let firstBridgeBall = UIView()
    let secondBridgeBall = UIView()
    let thirdBridgeBall = UIView()
    
    var stateLabel : UILabel!
    
    var animating = false
    
    @objc func nextAction() {
        guard animating == false else { return }
        switch step {
        case .first:
            step = .second
            break
        case .second:
            step = .third
            break
        case .third:
            step = .fourth
            break
        case .fourth:
            step = .fifth
            break
        case .fifth:
            step = .sixth
            break
        case .sixth:
            step = .seventh
            break
        case .seventh:
            step = .eight
            break
        case .eight:
            step = .first
            break
        }
        updateColors()
        updateLabels()
        resetAnimation()
    }

    @objc func previousAction() {
        guard animating == false else { return }
        switch step {
        case .first:
            step = .eight
            break
        case .second:
            step = .first
            break
        case .third:
            step = .second
            break
        case .fourth:
            step = .third
            break
        case .fifth:
            step = .fourth
            break
        case .sixth:
            step = .fifth
            break
        case .seventh:
            step = .sixth
            break
        case .eight:
            step = .seventh
            break
        }
        updateColors()
        updateLabels()
        resetAnimation()
    }
    
    func updateLabels() {
        stateLabel.text = step.string
    }
    
    func color(_ element: GenesisElement) -> (stroke: UIColor, fill: UIColor) {
        switch element {
        case .point:
            switch step {
                case .first:
                    return (purple, purple)
                default:
                return (.clear, .clear)
            }
        case .controlPoint, .handle:
            switch step {
            case .first:
                return (.clear, .clear)
            default:
                return (purple, .white)
            }
        case .joinLine:
            switch step {
            case .first, .second:
                return (.clear, .clear)
            default:
                return (.lightGray, .clear)
            }
        case .bezier:
            switch step {
            case .first:
                return (.clear, .clear)
            case .second, .fourth, .fifth, .sixth, .seventh:
                return (.clear, lighterGray)
            case .third, .eight:
                return (black, lighterGray)
            }
        case .bridge:
            switch step {
            case .first, .second, .third, .fourth:
                return (.clear, .clear)
            case .fifth, .sixth, .seventh, .eight:
                return (green, .clear)
            }
        case .bridgePoint:
            switch step {
            case .fourth, .fifth:
                return (.clear, green)
            default:
                return (.clear, .clear)
            }
        case .tangentPoint:
            switch step {
            case .seventh, .eight:
                return (.clear, fuxia)
            default:
                return (.clear, .clear)
            }
        case .tangent:
            switch step {
            case .seventh, .eight:
                return (fuxia, .clear)
            default:
                return (.clear, .clear)
            }
        case .bridgeTangentPoint:
            switch step {
            case .sixth, .seventh, .eight:
                return (.clear, fuxia)
            default:
                return (.clear, .clear)
            }
        }
    }
    
    func updateColors() {
        joinBezier.strokeColor = color(.bezier).stroke.cgColor
        joinBezier.fillColor = color(.bezier).fill.cgColor
        
        joinBezier.strokeEnd = 1.0
        
        armsConnection.strokeColor = color(.joinLine).stroke.cgColor
        leftArm.strokeColor = color(.handle).stroke.cgColor
        rightArm.strokeColor = color(.handle).stroke.cgColor
        leftHandle.strokeColor = color(.handle).stroke.cgColor
        leftHandle.fillColor = color(.handle).fill.cgColor
        rightHandle.strokeColor = color(.handle).stroke.cgColor
        rightHandle.fillColor = color(.handle).fill.cgColor
        
        leftArmBall.backgroundColor = color(.bridgePoint).fill
        rightArmBall.backgroundColor = color(.bridgePoint).fill
        armsConnectionBall.backgroundColor = color(.bridgePoint).fill
        
        firstBridgeBall.backgroundColor = color(.bridgeTangentPoint).fill
        secondBridgeBall.backgroundColor = color(.bridgeTangentPoint).fill
        
        firstBridge.strokeColor = color(.bridge).stroke.cgColor
        secondBridge.strokeColor = color(.bridge).stroke.cgColor
        thirdBridge.strokeColor = color(.tangent).stroke.cgColor
        
        thirdBridgeBall.backgroundColor = color(.tangentPoint).fill
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        startPoint = CGPoint(x: 0, y: canvasSize)
        endPoint = CGPoint(x: canvasSize, y: canvasSize / 2)
        
        controlPoint1 = CGPoint(x: 0, y: canvasSize / 2)
        controlPoint2 = CGPoint(x: canvasSize / 2, y: canvasSize / 3)
        
        canvas.frame = CGRect(x: padding, y: padding, width: canvasSize, height: canvasSize)
        canvas.borderColor = UIColor.white.cgColor
        canvas.borderWidth = 0.0
        view.layer.addSublayer(canvas)
        
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
        
        view.addSubview(leftHandleView)
        let leftHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        leftHandleView.addGestureRecognizer(leftHandlePan)
        
        let rightHandleView = UIView(frame: CGRect(x: controlPoint2.x + padding - 20, y: controlPoint2.y + padding - 20, width: 40, height: 40))
        rightHandleView.backgroundColor = .clear
        rightHandleView.tag = 2
        view.addSubview(rightHandleView)
        let rightHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        rightHandleView.addGestureRecognizer(rightHandlePan)
        
        startAnimationButton = UIButton(frame: CGRect(x: padding, y: canvasSize + padding, width: 60, height: 44))
        startAnimationButton.setTitleColor(.black, for: .normal)
        startAnimationButton.setTitle("Play", for: .normal)
        startAnimationButton.addTarget(self, action: #selector(animate), for: .touchUpInside)
        view.addSubview(startAnimationButton)
        
        resetAnimationButton = UIButton(frame: CGRect(x: padding * 2 + 60, y: canvasSize + padding, width: 60, height: 44))
        resetAnimationButton.setTitleColor(.black, for: .normal)
        resetAnimationButton.setTitle("Reset", for: .normal)
        resetAnimationButton.addTarget(self, action: #selector(resetAnimation), for: .touchUpInside)
        view.addSubview(resetAnimationButton)
        
        canvas.addSublayer(firstBridge)
        canvas.addSublayer(secondBridge)
        canvas.addSublayer(thirdBridge)
        
        view.addSubview(firstBridgeBall)
        view.addSubview(secondBridgeBall)
        view.addSubview(thirdBridgeBall)
        
        view.addSubview(leftArmBall)
        view.addSubview(armsConnectionBall)
        view.addSubview(rightArmBall)
        
        nextButton = UIButton(frame: CGRect(x: padding * 2, y: 20, width: 60, height: 44))
        nextButton.setTitleColor(.black, for: .normal)
        nextButton.setTitle(">", for: .normal)
        nextButton.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        view.addSubview(nextButton)
        
        previousButton = UIButton(frame: CGRect(x: padding, y: 20, width: 60, height: 44))
        previousButton.setTitleColor(.black, for: .normal)
        previousButton.setTitle("<", for: .normal)
        previousButton.addTarget(self, action: #selector(previousAction), for: .touchUpInside)
        view.addSubview(previousButton)
        
        stateLabel = UILabel(frame: CGRect(x: 2 * padding + padding - 20, y: 20, width: 60, height: 44))
        stateLabel.textColor = UIColor.black
        stateLabel.text = "1"
        view.addSubview(stateLabel)
        
        canvas.addSublayer(armsConnection)
        canvas.addSublayer(leftArm)
        canvas.addSublayer(rightArm)
        canvas.addSublayer(joinBezier)
        canvas.addSublayer(leftHandle)
        canvas.addSublayer(rightHandle)
        
        drawLayers()
    }
    
    func drawLayers() {
        
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        bezier.addCurve(to: CGPoint(x: endPoint.x, y:endPoint.y), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        joinBezier.frame = canvas.bounds
        joinBezier.path = bezier.cgPath
        joinBezier.lineWidth = 2
        
        leftHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint1.x, y: controlPoint1.y, width: handleSize, height: handleSize)).cgPath
        leftHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        leftHandle.lineWidth = 2
        
        rightHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint2.x, y: controlPoint2.y, width: handleSize, height: handleSize)).cgPath
        rightHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        rightHandle.lineWidth = 2
        
        let leftArmPath = UIBezierPath()
        leftArmPath.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        leftArmPath.addLine(to: controlPoint1)
        
        leftArm.frame = canvas.bounds
        leftArm.path = leftArmPath.cgPath
        leftArm.lineWidth = 2
        
        let rightArmPath = UIBezierPath()
        rightArmPath.move(to: CGPoint(x: endPoint.x, y: endPoint.y))
        rightArmPath.addLine(to: controlPoint2)
        
        rightArm.frame = canvas.bounds
        rightArm.path = rightArmPath.cgPath
        rightArm.lineWidth = 2
        
        let armsConnectionPath = UIBezierPath()
        armsConnectionPath.move(to: CGPoint(x: controlPoint1.x, y: controlPoint1.y))
        armsConnectionPath.addLine(to: controlPoint2)
        
        armsConnection.lineDashPattern = [3, 3, 3, 3]
        armsConnection.frame = canvas.bounds
        armsConnection.path = armsConnectionPath.cgPath
        armsConnection.lineWidth = 1
        
        let armBallSize : CGFloat = 6
        
        leftArmBall.frame = CGRect(x: padding + startPoint.x - armBallSize / 2, y: padding + startPoint.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        leftArmBall.layer.cornerRadius = armBallSize / 2
        
        armsConnectionBall.frame = CGRect(x: padding + controlPoint1.x - armBallSize / 2, y: padding + controlPoint1.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        armsConnectionBall.layer.cornerRadius = armBallSize / 2
        
        rightArmBall.frame = CGRect(x: padding + controlPoint2.x - armBallSize / 2, y: padding + controlPoint2.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        rightArmBall.layer.cornerRadius = armBallSize / 2
        
        firstBridgeBall.frame = CGRect(x: padding + startPoint.x - armBallSize / 2, y: padding + startPoint.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        firstBridgeBall.layer.cornerRadius = armBallSize / 2
        
        
        secondBridgeBall.frame = CGRect(x: padding + controlPoint1.x - armBallSize / 2, y: padding + controlPoint1.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        secondBridgeBall.layer.cornerRadius = armBallSize / 2
        
        thirdBridgeBall.frame = CGRect(x: padding + startPoint.x - armBallSize / 2, y: padding + startPoint.y - armBallSize / 2, width: armBallSize, height: armBallSize)
        thirdBridgeBall.layer.cornerRadius = armBallSize / 2
        
        let firstBridgePath = UIBezierPath()
        firstBridgePath.move(to: startPoint)
        firstBridgePath.addLine(to: controlPoint1)
        
        firstBridge.frame = canvas.bounds
        firstBridge.path = firstBridgePath.cgPath
        firstBridge.lineWidth = 2
        
        let secondBridgePath = UIBezierPath()
        secondBridgePath.move(to: controlPoint1)
        secondBridgePath.addLine(to: controlPoint2)
        
        secondBridge.frame = canvas.bounds
        secondBridge.path = secondBridgePath.cgPath
        secondBridge.lineWidth = 2
        
        let thirdBridgePath = UIBezierPath()
        thirdBridgePath.move(to: controlPoint1)
        thirdBridgePath.addLine(to: controlPoint2)
        thirdBridge.frame = canvas.bounds
        thirdBridge.path = thirdBridgePath.cgPath
        thirdBridge.lineWidth = 2
        
        updateColors()
        
        switch step {
        case .second, .third, .fourth:
            joinBezier.strokeEnd = 1.0
        default:
            joinBezier.strokeEnd = 0.0
        }
    }
    
    func resetAnimation() {
        
        let firstBridgePath = UIBezierPath()
        firstBridgePath.move(to: startPoint)
        firstBridgePath.addLine(to: controlPoint1)
        firstBridge.path = firstBridgePath.cgPath
        
        let secondBridgePath = UIBezierPath()
        secondBridgePath.move(to: controlPoint1)
        secondBridgePath.addLine(to: controlPoint2)
        secondBridge.path = secondBridgePath.cgPath
        
        leftArmBall.center = padded(startPoint)
        armsConnectionBall.center = padded(controlPoint1)
        rightArmBall.center = padded(controlPoint2)
        
        firstBridgeBall.center = leftArmBall.center
        secondBridgeBall.center = armsConnectionBall.center
        thirdBridgeBall.center = leftArmBall.center
        
        firstBridgeBall.layer.removeAllAnimations()
        secondBridgeBall.layer.removeAllAnimations()
        thirdBridgeBall.layer.removeAllAnimations()
        
        animating = false
    }
    
    func animate() {
        resetAnimation()
        animating = true
        resetAnimationButton.isEnabled = false
        startAnimationButton.isEnabled = false
        
        joinBezier.strokeStart = 0.0
        
        updateColors()
        
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
        displayLink.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        
        animatorLinear.addCompletion {
            _ in
            self.resetAnimationButton.isEnabled = true
            self.startAnimationButton.isEnabled = true
            self.firstBridge.path = firstBridgePath.cgPath
            self.secondBridge.path = secondBridgePath.cgPath
            
            self.firstBridge.removeAllAnimations()
            self.secondBridge.removeAllAnimations()
            displayLink.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            self.animating = false
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
        
        let fifthBridgePath = UIBezierPath()
        fifthBridgePath.move(to: padded(startPoint))
        fifthBridgePath.addCurve(to: padded(endPoint), controlPoint1: padded(controlPoint1), controlPoint2: padded(controlPoint2))
        
        let fifthAnimation = CAKeyframeAnimation(keyPath: "position")
        fifthAnimation.path = fifthBridgePath.cgPath
        fifthAnimation.duration = animationDuration
        fifthAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        fifthAnimation.fillMode = kCAFillModeBoth
        fifthAnimation.isRemovedOnCompletion = false
        thirdBridgeBall.layer.add(fifthAnimation, forKey:fifthAnimation.keyPath)
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeAnimation.fromValue = 0.0
        strokeAnimation.toValue = 1.0
        strokeAnimation.duration = animationDuration
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        strokeAnimation.fillMode = kCAFillModeBoth
        strokeAnimation.isRemovedOnCompletion = false
        joinBezier.add(strokeAnimation, forKey:strokeAnimation.keyPath)
    }
    
    func padded(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + padding, y: point.y + padding)
    }
    
    func unpadded(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - padding, y: point.y - padding)
    }
    
    @objc func update(displayLink: CADisplayLink) {
        let first = unpadded(firstBridgeBall.layer.presentation()!.position)
        let second = unpadded(secondBridgeBall.layer.presentation()!.position)
        
        let thirdBridgePath = UIBezierPath()
        thirdBridgePath.move(to: first)
        thirdBridgePath.addLine(to: second)
        thirdBridge.path = thirdBridgePath.cgPath
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        guard animating == false else { return }
        resetAnimation()
        switch (gesture.state) {
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            var x = gesture.view!.center.x + translation.x
            var y = gesture.view!.center.y + translation.y
            if x < 0 { x = 0 }
            if x > canvasSize + 2 * padding { x = canvasSize + 2 * padding }
            if y < 0 { y = 0 }
            if y > view.bounds.size.height { y = view.bounds.size.height }
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
            if y > view.bounds.size.height - padding { y = view.bounds.size.height - padding }
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
