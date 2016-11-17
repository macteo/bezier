import UIKit
import CoreLocation

let orangeTralio = UIColor(red: 255 / 255, green: 87 / 255, blue: 34 / 255, alpha: 1)

public enum DrawStep : Int {
    case first   = 1
    case second  = 2
    case third   = 3
    case fourth  = 4
    case fifth   = 5
    
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
        }
    }
}

public class DrawController : UIViewController, Stepper {
    public var step: Int = 1 {
        didSet {
            guard let drawStep = DrawStep(rawValue: step) else {
                stepsView.currentStep = oldValue
                return
            }
            _step = drawStep
            updateStep()
        }
    }
    
    let imageView = UIImageView()
    
    var _step = DrawStep.first
    
    var stepsView : StepsView!
    
    let steps : [DrawStep] = [.first, .second, .third, .fourth, .fifth]
    
    let graphicsView = GraphicsView()
    
    func updateStep() {
        switch _step {
        case .first:
            graphicsView.showCurve = false
            graphicsView.showHandles = false
            imageView.isHidden = true
            break;
        case .second:
            graphicsView.showCurve = true
            graphicsView.showHandles = false
            imageView.isHidden = true
            break;
        case .third:
            graphicsView.showCurve = true
            graphicsView.showHandles = true
            imageView.isHidden = true
        case .fourth:
            graphicsView.showCurve = true
            graphicsView.showHandles = true
            imageView.isHidden = false
        case .fifth:
            graphicsView.showCurve = true
            graphicsView.showHandles = true
            imageView.isHidden = false
            break;
        }
        graphicsView.setNeedsDisplay()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        graphicsView.frame = view.bounds
        graphicsView.backgroundColor = .clear
        view.addSubview(graphicsView)
        
        graphicsView.interpolationPoints = []
        graphicsView.setNeedsDisplay()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        stepsView = StepsView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        stepsView.delegate = self
        stepsView.autoresizingMask = .flexibleWidth
        stepsView.stepsCount = steps.count
        stepsView.currentStep = _step.rawValue
        view.addSubview(stepsView)
        
        imageView.image = UIImage(named: "map.png")
        imageView.frame = view.bounds
        imageView.contentMode = .center
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        updateStep()
    }
    
    func coordinate(point: CGPoint) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: 45.891902, longitude: 11.039850)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: graphicsView)
        graphicsView.interpolationPoints.append(point)
        graphicsView.setNeedsDisplay()
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        graphicsView.interpolationPoints.removeAll()
        graphicsView.setNeedsDisplay()
    }
}
