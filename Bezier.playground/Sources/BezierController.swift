import UIKit


let canvasSize : CGFloat = 300

extension Double {
    func format(d: Int) -> String {
        return String(format: "%.\(d)f", self)
    }
}

extension Float {
    func format(d: Int) -> String {
        return String(format: "%.\(d)f", self)
    }
}

extension CGFloat {
    func format(d: Int) -> String {
        return String(format: "%.\(d)f", self)
    }
}

public class BezierController : UIViewController {
    var controlPoint1 : CGPoint!
    var controlPoint2 : CGPoint!
    let canvas = CALayer()
    let joinBezier = CAShapeLayer()
    let leftHandle = CAShapeLayer()
    let rightHandle = CAShapeLayer()
    let lefArm = CAShapeLayer()
    let rightArm = CAShapeLayer()
    let handleSize : CGFloat = 10
    var ball : UIView!
    let animationDuration : TimeInterval = 2
    let ballSize : CGFloat = 30
    let padding : CGFloat = 100
    let verticalProjection = UIView()
    let horizontalProjection = UIView()
    let ballPadding : CGFloat = 30
    
    let control1Label = UILabel(frame: CGRect(x: 20, y: -14, width: 80, height: 40))
    let control2Label = UILabel(frame: CGRect(x: -25, y: 14, width: 80, height: 40))
    
    var startAnimationButton : UIButton!
    var resetAnimationButton : UIButton!
    
    var timeBall : UIView!
    var controlBall : UIView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        controlPoint1 = CGPoint(x: 0, y: canvasSize)
        controlPoint2 = CGPoint(x: canvasSize, y: 0)
        
        control1Label.textColor = .white
        control2Label.textColor = .white
        
        control1Label.font = UIFont.systemFont(ofSize: 14)
        control2Label.font = UIFont.systemFont(ofSize: 14)
        
        canvas.frame = CGRect(x: padding, y: padding, width: canvasSize, height: canvasSize)
        canvas.borderColor = UIColor.white.cgColor
        canvas.borderWidth = 0.5
        view.layer.addSublayer(canvas)
        
        verticalProjection.frame = CGRect(x: padding, y: padding, width: 1, height: canvasSize + ballPadding + ballSize / 2)
        verticalProjection.backgroundColor = .white
        view.addSubview(verticalProjection)
        
        horizontalProjection.frame = CGRect(x: padding, y: padding + canvasSize, width: canvasSize + ballPadding + ballSize, height: 1)
        horizontalProjection.backgroundColor = .white
        view.addSubview(horizontalProjection)
        
        let pointSize : CGFloat = 6
        let originPoint = CAShapeLayer()
        originPoint.path = UIBezierPath(ovalIn: CGRect(x: 0, y: canvasSize, width: pointSize, height: pointSize)).cgPath
        originPoint.frame = CGRect(x: -pointSize / 2, y: -pointSize / 2, width: pointSize, height: pointSize)
        canvas.addSublayer(originPoint)
        
        let finalPoint = CAShapeLayer()
        finalPoint.path = UIBezierPath(ovalIn: CGRect(x: canvasSize, y: 0, width: pointSize, height: pointSize)).cgPath
        finalPoint.frame = CGRect(x: -pointSize / 2, y: -pointSize / 2, width: pointSize, height: pointSize)
        canvas.addSublayer(finalPoint)
        
        let leftHandleView = UIView(frame: CGRect(x: controlPoint1.x + padding - 20, y: controlPoint1.y + padding - 20, width: 40, height: 40))
        leftHandleView.backgroundColor = .clear
        leftHandleView.tag = 1
        self.view.addSubview(leftHandleView)
        let leftHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        leftHandleView.addGestureRecognizer(leftHandlePan)
        leftHandleView.addSubview(control1Label)
        
        let rightHandleView = UIView(frame: CGRect(x: controlPoint2.x + padding - 20, y: controlPoint2.y + padding - 20, width: 40, height: 40))
        rightHandleView.backgroundColor = .clear
        rightHandleView.tag = 2
        self.view.addSubview(rightHandleView)
        let rightHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        rightHandleView.addGestureRecognizer(rightHandlePan)
        rightHandleView.addSubview(control2Label)
        
        canvas.addSublayer(leftHandle)
        canvas.addSublayer(rightHandle)
        canvas.addSublayer(lefArm)
        canvas.addSublayer(rightArm)
        canvas.addSublayer(joinBezier)
        
        drawLayers()
        
        ball = UIView(frame: CGRect(x: 0, y: 0, width: ballSize, height: ballSize))
        ball.layer.cornerRadius = ball.frame.size.width / 2
        ball.backgroundColor = .red
        view.addSubview(ball)
        
        ball.center.x = canvasSize + padding + ballPadding + ballSize
        ball.center.y = canvasSize + padding
        
        timeBall = UIView(frame: CGRect(x: 0, y: 0, width: ballSize / 2, height: ballSize / 2))
        timeBall.layer.cornerRadius = timeBall.frame.size.width / 2
        timeBall.backgroundColor = .orange
        view.addSubview(timeBall)
        
        timeBall.center.y = canvasSize + padding + ballPadding + ballSize / 2
        timeBall.center.x = padding
        
        startAnimationButton = UIButton(frame: CGRect(x: padding, y: canvasSize + padding + ballPadding + ballSize, width: 60, height: 44))
        startAnimationButton.setTitle("Play", for: .normal)
        startAnimationButton.addTarget(self, action: #selector(animateBall), for: .touchUpInside)
        view.addSubview(startAnimationButton)
        
        resetAnimationButton = UIButton(frame: CGRect(x: padding * 2 + 60, y: canvasSize + padding + ballPadding + ballSize, width: 60, height: 44))
        resetAnimationButton.setTitle("Reset", for: .normal)
        resetAnimationButton.addTarget(self, action: #selector(resetAnimation), for: .touchUpInside)
        view.addSubview(resetAnimationButton)
        
        controlBall = UIView(frame: CGRect(x: 0, y: 0, width: ballSize / 2, height: ballSize / 2))
        controlBall.layer.cornerRadius = controlBall.frame.size.width / 2
        controlBall.backgroundColor = .lightGray
        view.addSubview(controlBall)
        
        controlBall.center.y = canvasSize + padding
        controlBall.center.x = padding
        controlBall.isUserInteractionEnabled = false
    }
    
    func resetAnimation() {
        self.ball.center.y = canvasSize + self.padding
        self.controlBall.center.y = canvasSize + self.padding
        self.horizontalProjection.center.y = self.padding + canvasSize
        self.verticalProjection.center.x = self.padding
        self.timeBall.center.x = self.padding
        self.controlBall.center.x = self.padding
    }
    
    func animateBall() {
        resetAnimation()
        self.resetAnimationButton.isEnabled = false
        self.startAnimationButton.isEnabled = false
        
        let animator = UIViewPropertyAnimator(duration: self.animationDuration, timingParameters: self.timingParameters)
        animator.addAnimations {
            self.ball.center.y = self.padding
            self.controlBall.center.y = self.padding
            self.horizontalProjection.center.y = self.padding
        }
        animator.addCompletion {
            completion in
            if completion == .end {
                self.resetAnimationButton.isEnabled = true
                self.startAnimationButton.isEnabled = true
            }
        }
        animator.startAnimation()
        
        let animatorLinear = UIViewPropertyAnimator(duration: self.animationDuration, curve: .linear, animations: {
            self.timeBall.center.x = canvasSize + self.padding
            self.controlBall.center.x = canvasSize + self.padding
            self.verticalProjection.center.x = self.padding + canvasSize
        })
        animatorLinear.startAnimation()
    }
    
    var timingParameters : UITimingCurveProvider {
        return UICubicTimingParameters(controlPoint1: control1, controlPoint2: control2)
    }
    
    var control1 : CGPoint {
        let c1 = CGPoint(x: controlPoint1.x / canvasSize, y: (-controlPoint1.y + canvasSize) / canvasSize)
        return c1
    }
    
    var control2 : CGPoint {
        let c2 = CGPoint(x: controlPoint2.x / canvasSize, y: (-controlPoint2.y + canvasSize) / canvasSize)
        return c2
    }
    
    func drawLayers() {
        
        let bezier = UIBezierPath()
        bezier.move(to: CGPoint(x:0, y: canvasSize))
        bezier.addCurve(to: CGPoint(x: canvasSize, y:0), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
        
        joinBezier.frame = canvas.bounds
        joinBezier.path = bezier.cgPath
        joinBezier.lineWidth = 3
        joinBezier.fillColor = UIColor.clear.cgColor
        joinBezier.strokeColor = UIColor.orange.cgColor
        
        leftHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint1.x, y: controlPoint1.y, width: handleSize, height: handleSize)).cgPath
        leftHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        leftHandle.fillColor = UIColor.green.cgColor
        
        rightHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint2.x, y: controlPoint2.y, width: handleSize, height: handleSize)).cgPath
        rightHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        rightHandle.fillColor = UIColor.yellow.cgColor
        
        let leftArmPath = UIBezierPath()
        leftArmPath.move(to: CGPoint(x:0, y: canvasSize))
        leftArmPath.addLine(to: controlPoint1)
        
        lefArm.frame = canvas.bounds
        lefArm.path = leftArmPath.cgPath
        lefArm.lineWidth = 3
        lefArm.fillColor = UIColor.clear.cgColor
        lefArm.strokeColor = UIColor.green.cgColor
        
        let rightArmPath = UIBezierPath()
        rightArmPath.move(to: CGPoint(x: canvasSize, y:0))
        
        rightArmPath.addLine(to: controlPoint2)
        
        rightArm.frame = canvas.bounds
        rightArm.path = rightArmPath.cgPath
        rightArm.lineWidth = 3
        rightArm.fillColor = UIColor.clear.cgColor
        rightArm.strokeColor = UIColor.yellow.cgColor
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch (gesture.state) {
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            var x = gesture.view!.center.x + translation.x
            var y = gesture.view!.center.y + translation.y
            if x < padding { x = padding }
            if x > canvasSize + padding { x = canvasSize + padding }
            if y < -padding { y = -padding }
            if y > view.bounds.size.height - padding { y = view.bounds.size.height - padding }
            gesture.view!.center =  CGPoint(x: x, y: y)
            gesture.setTranslation(CGPoint(x:0, y:0), in: gesture.view)
            
            var point = controlPoint1!
            if gesture.view?.tag == 2 {
                point = controlPoint2!
            }
            x = point.x + translation.x
            y = point.y + translation.y
            
            if x < 0 { x = 0 }
            if x > canvasSize { x = canvasSize }
            if y < -padding { y = -padding }
            if y > view.bounds.size.height - padding { y = view.bounds.size.height - padding }
            point = CGPoint(x: x, y: y)
            if gesture.view?.tag == 1 {
                control1Label.text = "\(control1.x.format(d: 1)), \(control1.y.format(d: 1))"
                controlPoint1 = point
            } else {
                control2Label.text = "\(control2.x.format(d: 1)), \(control2.y.format(d: 1))"
                controlPoint2 = point
            }
            
            drawLayers()
        default:
            break
        }
    }
}
