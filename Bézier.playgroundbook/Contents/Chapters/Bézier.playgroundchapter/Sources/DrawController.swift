import UIKit
import CoreLocation

let orangeTralio = UIColor(red: 255 / 255, green: 87 / 255, blue: 34 / 255, alpha: 1)

public enum DrawStep : Int {
    case first   = 1
    case second  = 2
    case third   = 3
    case fourth  = 4
    case fifth   = 5
    case sixth   = 6
    
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
        }
    }
}

let mapboxAccessToken = "pk.eyJ1IjoibWFjdGVvIiwiYSI6ImNpdm05bzMxeTAwaXYyenBwcWo1ZXg4dDAifQ.nEfQR4wsks-C6VonIs3auQ"

public class DrawController : UIViewController, Stepper {
    var locations = [CLLocationCoordinate2D]()
    
    var _step = DrawStep.first
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
    
    var stepsView : StepsView!
    
    let steps : [DrawStep] = [.first, .second, .third, .fourth, .fifth, .sixth]
    
    let graphicsView = GraphicsView()
    let pathView = PathView()
    
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
            graphicsView.showCurve = false
            graphicsView.showHandles = true
            imageView.isHidden = false
        case .fifth:
            graphicsView.showCurve = true
            graphicsView.showHandles = true
            imageView.isHidden = false
            break;
        case .sixth:
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
        
        pathView.frame = view.bounds
        pathView.backgroundColor = .clear
        pathView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        view.addSubview(pathView)
        pathView.interpolationPoints = []
        pathView.setNeedsDisplay()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(longPressGestureRecognizer)
        
        stepsView = StepsView(frame: CGRect(x: 0, y: view.frame.size.height - 44, width: view.frame.size.width, height: 44))
        stepsView.delegate = self
        stepsView.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        stepsView.stepsCount = steps.count
        stepsView.currentStep = _step.rawValue
        view.addSubview(stepsView)
        updateStep()
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        pathView.setNeedsDisplay()
        graphicsView.setNeedsDisplay()
        
        coordinator.animate(alongsideTransition: { (context) in
            self.imageView.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }, completion: nil)
    }

    func matchRoute() {
        let options = MapMatchOptions()
        options.profile = .driving
        
        guard locations.count >= 2 else { return }
        
        let matcher = MapMatcher(accessToken: mapboxAccessToken)
        
        let _ = matcher.match(coordinates: locations, options: options) { (routes, attribution, error) in
            guard error == nil else {
                print("Error \(error!.localizedDescription)")
                self.pathView.interpolationPoints.removeAll()
                DispatchQueue.main.async {
                    self.pathView.setNeedsDisplay()
                }
                return
            }
            guard let routes = routes else {
                print("No routes found")
                self.pathView.interpolationPoints.removeAll()
                DispatchQueue.main.async {
                    self.pathView.setNeedsDisplay()
                }
                return
            }
            
            let merge = routes.flatMap { $0 }
            let points = merge.map { self.point(coordinate: $0) }
            self.pathView.interpolationPoints = points
            
            DispatchQueue.main.async {
                self.pathView.setNeedsDisplay()
            }
        }
    }
    
    func coordinate(point: CGPoint) -> CLLocationCoordinate2D {
        
        let latitude : Double = 45.897261 - (45.897261 - 45.887759) * Double(point.y) / 768
        let longitude : Double = 11.029820 + (11.047974 - 11.029820) * Double(point.x) / 1024
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func point(coordinate: CLLocationCoordinate2D) -> CGPoint {
        
        let y : CGFloat = CGFloat(45.887759 - coordinate.latitude) / (45.897261 - 45.887759) * 768 + 768
        let x : CGFloat = CGFloat(coordinate.longitude - 11.029820) / (11.047974 - 11.029820) * 1024
        
        return CGPoint(x: x, y: y)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: graphicsView)
        graphicsView.interpolationPoints.append(point)
        graphicsView.setNeedsDisplay()
        
        let coordinate = self.coordinate(point: point)
        locations.append(coordinate)

        if _step == .sixth {
            matchRoute()
        }
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        graphicsView.interpolationPoints.removeAll()
        graphicsView.setNeedsDisplay()
        locations.removeAll()
        pathView.interpolationPoints.removeAll()
        pathView.setNeedsDisplay()
    }
}
