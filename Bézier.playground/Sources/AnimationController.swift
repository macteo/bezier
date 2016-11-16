import UIKit

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

public class AnimationController : UIViewController {
    let canvasSize : CGFloat = 300
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
    let control2Label = UILabel(frame: CGRect(x: -25, y: 18, width: 80, height: 40))
    
    var startAnimationButton : UIButton!
    var resetAnimationButton : UIButton!
    let progressView = UIProgressView()
    
    var easeButton : UIButton!
    var linearButton : UIButton!
    var easeInButton : UIButton!
    var easeOutButton : UIButton!
    var easeInOutButton : UIButton!
    
    var leftHandleView : UIView!
    var rightHandleView : UIView!
    
    var timeBall : UIView!
    var controlBall : UIView!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        controlPoint1 = CGPoint(x: 0, y: canvasSize)
        controlPoint2 = CGPoint(x: canvasSize, y: 0)
        
        control1Label.textColor = purple
        control2Label.textColor = purple
        
        control1Label.font = UIFont.systemFont(ofSize: 14)
        control2Label.font = UIFont.systemFont(ofSize: 14)
        
        canvas.frame = CGRect(x: padding, y: padding, width: canvasSize, height: canvasSize)
        canvas.borderColor = UIColor.purple.cgColor
        canvas.borderWidth = 1.0
        view.layer.addSublayer(canvas)
        
        verticalProjection.frame = CGRect(x: padding, y: padding, width: 1, height: canvasSize + ballPadding + ballSize / 2)
        verticalProjection.backgroundColor = purple
        view.addSubview(verticalProjection)
        
        horizontalProjection.frame = CGRect(x: padding, y: padding + canvasSize, width: canvasSize + ballPadding + ballSize, height: 1)
        horizontalProjection.backgroundColor = purple
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
        
        leftHandleView = UIView(frame: CGRect(x: controlPoint1.x + padding - 20, y: controlPoint1.y + padding - 20, width: 40, height: 40))
        leftHandleView.backgroundColor = .clear
        leftHandleView.tag = 1
        self.view.addSubview(leftHandleView)
        let leftHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        leftHandleView.addGestureRecognizer(leftHandlePan)
        leftHandleView.addSubview(control1Label)
        
        rightHandleView = UIView(frame: CGRect(x: controlPoint2.x + padding - 20, y: controlPoint2.y + padding - 20, width: 40, height: 40))
        rightHandleView.backgroundColor = .clear
        rightHandleView.tag = 2
        self.view.addSubview(rightHandleView)
        let rightHandlePan = UIPanGestureRecognizer(target: self, action: #selector(pan(gesture:)))
        rightHandleView.addGestureRecognizer(rightHandlePan)
        rightHandleView.addSubview(control2Label)
        
        canvas.addSublayer(lefArm)
        canvas.addSublayer(leftHandle)
        canvas.addSublayer(rightArm)
        canvas.addSublayer(rightHandle)
        
        canvas.addSublayer(joinBezier)
        
        drawLayers()
        
        ball = UIView(frame: CGRect(x: 0, y: 0, width: ballSize, height: ballSize))
        ball.layer.cornerRadius = ball.frame.size.width / 2
        ball.backgroundColor = green
        view.addSubview(ball)
        
        ball.center.x = canvasSize + padding + ballPadding + ballSize
        ball.center.y = canvasSize + padding
        
        timeBall = UIView(frame: CGRect(x: 0, y: 0, width: ballSize / 2, height: ballSize / 2))
        timeBall.layer.cornerRadius = timeBall.frame.size.width / 2
        timeBall.backgroundColor = fuxia
        view.addSubview(timeBall)
        
        timeBall.center.y = canvasSize + padding + ballPadding + ballSize / 2
        timeBall.center.x = padding
        
        startAnimationButton = UIButton(frame: CGRect(x: 10, y: 44, width: 44, height: 44))
        
        let playImage = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
        startAnimationButton.setImage(playImage, for: .normal)
        startAnimationButton.tintColor = blue
        startAnimationButton.addTarget(self, action: #selector(animateBall), for: .touchUpInside)
        startAnimationButton.autoresizingMask = .flexibleRightMargin
        view.addSubview(startAnimationButton)
        
        resetAnimationButton = UIButton(frame: CGRect(x: view.frame.size.width - 10 - 44, y: 44, width: 44, height: 44))
        let resetImage = UIImage(named: "reset")?.withRenderingMode(.alwaysTemplate)
        resetAnimationButton.setImage(resetImage, for: .normal)
        resetAnimationButton.tintColor = blue
        resetAnimationButton.addTarget(self, action: #selector(resetAnimation), for: .touchUpInside)
        resetAnimationButton.autoresizingMask = .flexibleLeftMargin
        view.addSubview(resetAnimationButton)
        
        progressView.frame = CGRect(x: 10 * 2 + 44, y: 44 + 20, width: view.frame.size.width - (20 + 44) * 2, height: 6)
        progressView.progressTintColor = blue
        progressView.setProgress(0.0, animated: false)
        progressView.autoresizingMask = .flexibleWidth
        view.addSubview(progressView)
        
        controlBall = UIView(frame: CGRect(x: 0, y: 0, width: ballSize / 2, height: ballSize / 2))
        controlBall.layer.cornerRadius = controlBall.frame.size.width / 2
        controlBall.backgroundColor = .lightGray
        view.addSubview(controlBall)
        
        controlBall.center.y = canvasSize + padding
        controlBall.center.x = padding
        controlBall.isUserInteractionEnabled = false
        
        drawEaseButtons()
    }
    
    func drawEaseButtons() {
        easeButton = UIButton(frame: CGRect(x: padding, y: padding + canvasSize + 64, width: 44, height: 44))
        let easeImage = UIImage(named: "ease")?.withRenderingMode(.alwaysTemplate)
        easeButton.setImage(easeImage, for: .normal)
        easeButton.tintColor = blue
        easeButton.addTarget(self, action: #selector(setEase), for: .touchUpInside)
        easeButton.autoresizingMask = [.flexibleRightMargin]
        easeButton.layer.borderColor = blue.cgColor
        easeButton.layer.borderWidth = 1
        easeButton.layer.cornerRadius = 6
        view.addSubview(easeButton)
        
        linearButton = UIButton(frame: CGRect(x: padding + 20 + 44, y: padding + canvasSize + 64, width: 44, height: 44))
        let linearImage = UIImage(named: "linear")?.withRenderingMode(.alwaysTemplate)
        linearButton.setImage(linearImage, for: .normal)
        linearButton.tintColor = blue
        linearButton.addTarget(self, action: #selector(setLinear), for: .touchUpInside)
        linearButton.autoresizingMask = [.flexibleRightMargin]
        linearButton.layer.borderColor = blue.cgColor
        linearButton.layer.borderWidth = 1
        linearButton.layer.cornerRadius = 6
        view.addSubview(linearButton)

        easeInButton = UIButton(frame: CGRect(x: padding + (20 + 44) * 2, y: padding + canvasSize + 64, width: 44, height: 44))
        let easeInImage = UIImage(named: "ease in")?.withRenderingMode(.alwaysTemplate)
        easeInButton.setImage(easeInImage, for: .normal)
        easeInButton.tintColor = blue
        easeInButton.addTarget(self, action: #selector(setEaseIn), for: .touchUpInside)
        easeInButton.autoresizingMask = [.flexibleRightMargin]
        easeInButton.layer.borderColor = blue.cgColor
        easeInButton.layer.borderWidth = 1
        easeInButton.layer.cornerRadius = 6
        view.addSubview(easeInButton)

        easeOutButton = UIButton(frame: CGRect(x: padding + (20 + 44) * 3, y: padding + canvasSize + 64, width: 44, height: 44))
        let easeOutImage = UIImage(named: "ease out")?.withRenderingMode(.alwaysTemplate)
        easeOutButton.setImage(easeOutImage, for: .normal)
        easeOutButton.tintColor = blue
        easeOutButton.addTarget(self, action: #selector(setEaseOut), for: .touchUpInside)
        easeOutButton.autoresizingMask = [.flexibleRightMargin]
        easeOutButton.layer.borderColor = blue.cgColor
        easeOutButton.layer.borderWidth = 1
        easeOutButton.layer.cornerRadius = 6
        view.addSubview(easeOutButton)
        
        easeInOutButton = UIButton(frame: CGRect(x: padding + (20 + 44) * 4, y: padding + canvasSize + 64, width: 44, height: 44))
        let easeInOutImage = UIImage(named: "ease in out")?.withRenderingMode(.alwaysTemplate)
        easeInOutButton.setImage(easeInOutImage, for: .normal)
        easeInOutButton.tintColor = blue
        easeInOutButton.addTarget(self, action: #selector(setEaseInOut), for: .touchUpInside)
        easeInOutButton.autoresizingMask = [.flexibleRightMargin]
        easeInOutButton.layer.borderColor = blue.cgColor
        easeInOutButton.layer.borderWidth = 1
        easeInOutButton.layer.cornerRadius = 6
        view.addSubview(easeInOutButton)
    }
    
    func setLinear() {
        controlPoint1 = CGPoint(x: 0 * canvasSize, y: 1 * canvasSize)
        controlPoint2 = CGPoint(x: 1 * canvasSize, y: 0 * canvasSize)
        alignHandleView()
        drawLayers()
    }

    func setEase() {
        controlPoint1 = CGPoint(x: 0.25 * canvasSize, y: 0.9 * canvasSize)
        controlPoint2 = CGPoint(x: 0.25 * canvasSize, y: 0 * canvasSize)
        alignHandleView()
        drawLayers()
    }
    
    func setEaseIn() {
        controlPoint1 = CGPoint(x: 0.42 * canvasSize, y: 1 * canvasSize)
        controlPoint2 = CGPoint(x: 1 * canvasSize, y: 0 * canvasSize)
        alignHandleView()
        drawLayers()
    }
    
    func setEaseOut() {
        controlPoint1 = CGPoint(x: 0 * canvasSize, y: 1 * canvasSize)
        controlPoint2 = CGPoint(x: 0.58 * canvasSize, y: 0 * canvasSize)
        alignHandleView()
        drawLayers()
    }
    
    func setEaseInOut() {
        controlPoint1 = CGPoint(x: 0.42 * canvasSize, y: 1 * canvasSize)
        controlPoint2 = CGPoint(x: 0.58 * canvasSize, y: 0 * canvasSize)
        alignHandleView()
        drawLayers()
    }
    
    func alignHandleView() {
        control1Label.text = "\(control1.x.format(d: 2)), \(control1.y.format(d: 2))"
        control2Label.text = "\(control2.x.format(d: 2)), \(control2.y.format(d: 2))"
    
        leftHandleView.center = padded(controlPoint1)
        rightHandleView.center = padded(controlPoint2)
    }
    
    func resetAnimation() {
        progressView.setProgress(0, animated: false)
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
        progressView.progress = 1
        
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
                self.progressView.setProgress(0, animated: false)
            }
        }
        animator.startAnimation()
        
        let animatorLinear = UIViewPropertyAnimator(duration: self.animationDuration, curve: .linear, animations: {
            self.progressView.layoutIfNeeded()
            self.timeBall.center.x = self.self.canvasSize + self.padding
            self.controlBall.center.x = self.self.canvasSize + self.padding
            self.verticalProjection.center.x = self.padding + self.self.canvasSize
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
        joinBezier.strokeColor = fuxia.cgColor
        
        leftHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint1.x, y: controlPoint1.y, width: handleSize, height: handleSize)).cgPath
        leftHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        leftHandle.fillColor = UIColor.white.cgColor
        leftHandle.strokeColor = green.cgColor
        leftHandle.lineWidth = 2
        
        rightHandle.path = UIBezierPath(ovalIn: CGRect(x: controlPoint2.x, y: controlPoint2.y, width: handleSize, height: handleSize)).cgPath
        rightHandle.frame = CGRect(x: -handleSize / 2, y: -handleSize / 2, width: handleSize, height: handleSize)
        rightHandle.fillColor = UIColor.white.cgColor
        rightHandle.strokeColor = UIColor.blue.cgColor
        rightHandle.lineWidth = 2
        
        let leftArmPath = UIBezierPath()
        leftArmPath.move(to: CGPoint(x:0, y: canvasSize))
        leftArmPath.addLine(to: controlPoint1)
        
        lefArm.frame = canvas.bounds
        lefArm.path = leftArmPath.cgPath
        lefArm.lineWidth = 3
        lefArm.fillColor = UIColor.white.cgColor
        lefArm.strokeColor = green.cgColor
        
        let rightArmPath = UIBezierPath()
        rightArmPath.move(to: CGPoint(x: canvasSize, y:0))
        
        rightArmPath.addLine(to: controlPoint2)
        
        rightArm.frame = canvas.bounds
        rightArm.path = rightArmPath.cgPath
        rightArm.lineWidth = 3
        rightArm.fillColor = UIColor.white.cgColor
        rightArm.strokeColor = UIColor.blue.cgColor
    }
    
    func padded(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x + padding, y: point.y + padding)
    }
    
    func unpadded(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x - padding, y: point.y - padding)
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch (gesture.state) {
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            var x = gesture.view!.center.x + translation.x
            var y = gesture.view!.center.y + translation.y
            if x < padding { x = padding }
            if x > canvasSize + padding { x = canvasSize + padding }
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
            
            if x < 0 { x = 0 }
            if x > canvasSize { x = canvasSize }
            if y < -padding { y = -padding }
            if y > view.bounds.size.height - padding { y = view.bounds.size.height - padding }
            point = CGPoint(x: x, y: y)
            if gesture.view?.tag == 1 {
                control1Label.text = "\(control1.x.format(d: 2)), \(control1.y.format(d: 2))"
                controlPoint1 = point
            } else {
                control2Label.text = "\(control2.x.format(d: 2)), \(control2.y.format(d: 2))"
                controlPoint2 = point
            }
            
            drawLayers()
        default:
            break
        }
    }
}
