import UIKit

let orangeTralio = UIColor(red: 255 / 255, green: 87 / 255, blue: 34 / 255, alpha: 1)

public class DrawController : UIViewController {
    let graphicsView = GraphicsView()
    
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
