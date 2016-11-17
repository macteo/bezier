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
        
        imageView.image = UIImage(named: "map.png")
        imageView.frame = view.bounds
        imageView.contentMode = .center
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)
        
        graphicsView.frame = view.bounds
        graphicsView.backgroundColor = .clear
        graphicsView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        updateStep()
    }
    
    func coordinate(point: CGPoint) -> CLLocationCoordinate2D {
        
        let latitude : Double = 45.887759 + (45.897261 - 45.887759) * Double(point.x) / 1024
        let longitude : Double = 11.047974 - (11.047974 - 11.029820) * Double(point.y) / 768
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // SW(45.887759, 11.029820) - NE(45.897261, 11.047974)
    
    func tap(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: graphicsView)
        graphicsView.interpolationPoints.append(point)
        graphicsView.setNeedsDisplay()
        
        let coordinate = self.coordinate(point: point)
        print("coordinate \(coordinate) - point \(point)")
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        graphicsView.interpolationPoints.removeAll()
        graphicsView.setNeedsDisplay()
    }
}
