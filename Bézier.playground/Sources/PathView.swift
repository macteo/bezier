import UIKit

public class PathView : UIView {
    var interpolationPoints = [CGPoint]()
    var lineWidth : CGFloat = 6
    var lineColor : UIColor = UIColor.orange.withAlphaComponent(0.7)
    
    public override func draw(_ rect: CGRect) {
        guard interpolationPoints.count > 0 else { return }
        
        // Dashed line drawing
        let dashedConnectors = UIBezierPath()
        var ii = 0
        while ii < interpolationPoints.count {
            let point = interpolationPoints[ii]
            if interpolationPoints.count > 1 {
                if ii == 0 {
                    dashedConnectors.move(to: point)
                } else {
                    dashedConnectors.addLine(to: point)
                }
            }
            ii = ii + 1
        }
        
        dashedConnectors.lineWidth = 5
        UIColor(colorLiteralRed: 1, green: 0.4, blue: 0.4, alpha: 0.7).setStroke()
        dashedConnectors.stroke()
        
        // Interpolation points drawing
        for point in interpolationPoints {
            let pointPath = UIBezierPath(ovalIn: CGRect(x:point.x - 4, y:point.y - 4, width: 8, height: 8))
            UIColor.red.setFill()
            pointPath.fill()
        }
    }
}

