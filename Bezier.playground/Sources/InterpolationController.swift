import UIKit
import MapKit

let mapboxAccessToken = "YOUR MAPBOX TOKEN"
let orangeTralio = UIColor(red: 255 / 255, green: 87 / 255, blue: 34 / 255, alpha: 1)

public class InterpolationController : UIViewController {
    let graphicsView = GraphicsView()
    let mapView = MKMapView()
    var locations = [CLLocationCoordinate2D]()
    var matchedRoutes = [MKPolyline]()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.frame = view.bounds
        
        mapView.mapType = .standard
        mapView.showsPointsOfInterest = true
        mapView.showsBuildings = true
        mapView.showsCompass = true
        mapView.delegate = self
        
        let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: 45.888378, longitude: 11.041708), 2000, 2000)
        mapView.setRegion(region, animated: false)
        view.addSubview(mapView)
        
        graphicsView.frame = view.bounds
        graphicsView.backgroundColor = .clear
        view.addSubview(graphicsView)
        
        graphicsView.interpolationPoints = [CGPoint(x: 50, y: 50), CGPoint(x: 150, y: 150), CGPoint(x: 300, y: 50)]
        graphicsView.setNeedsDisplay()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap(gesture:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
        longPressGestureRecognizer.numberOfTouchesRequired = 1
        view.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func tap(gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: graphicsView)
        graphicsView.interpolationPoints.append(point)
        graphicsView.setNeedsDisplay()
        matchRoute()
    }
    
    func longPress(gesture: UILongPressGestureRecognizer) {
        graphicsView.interpolationPoints.removeAll()
        graphicsView.setNeedsDisplay()
        locations.removeAll()
        mapView.removeOverlays(mapView.overlays)
    }
    
    func matchRoute() {
        guard UIApplication.shared.applicationState == .active else { return }
        
        let options = MapMatchOptions()
        options.profile = .walking

        locations.append(CLLocationCoordinate2D(latitude: 45.895529, longitude: 11.037185))
        locations.append(CLLocationCoordinate2D(latitude: 45.894141, longitude: 11.037966))
        locations.append(CLLocationCoordinate2D(latitude: 45.893895, longitude: 11.038827))
        locations.append(CLLocationCoordinate2D(latitude: 45.892950, longitude: 11.040166))
        
        guard locations.count >= 2 else { return }
        
        let matcher = MapMatcher(accessToken: mapboxAccessToken)
        
        let _ = matcher.match(coordinates: locations, options: options) { (routes, attribution, error) in
            guard error == nil else {
                print("Error \(error!.localizedDescription)")
                return
            }
            guard let routes = routes else {
                print("No routes found")
                return
            }
            print("Calculating routes")
            
            let merge = routes.flatMap { $0 }
            
            let polyline = MKPolyline(coordinates: merge, count: merge.count)
            
            DispatchQueue.main.async {
                self.mapView.add(polyline)
            }
        }
    }
}

extension InterpolationController : MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            guard let annotation = view.annotation else { return }
            if annotation.isKind(of: MKUserLocation.self) {
                view.superview?.bringSubview(toFront: view)
            } else {
                view.superview?.sendSubview(toBack: view)
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            // renderer.strokeColor = UIColor(red: 74/255, green: 144/255, blue: 226/255, alpha: 1)
            if let title = overlay.title, title == "Route" {
                renderer.strokeColor = orangeTralio.withAlphaComponent(0.8)
                renderer.lineWidth = 4.0
            } else {
                renderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
                renderer.lineWidth = 6.0
            }
            
            return renderer
        } else {
            return MKCircleRenderer(overlay: overlay)
        }
    }
}
