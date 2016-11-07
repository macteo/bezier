import UIKit

public class GraphicsView : UIView {
    var interpolationPoints = [CGPoint]()
    var closed = false
    let useHermite = true
    var interpolationAlpha : CGFloat = 0.35
    var showHandles = false
    var showCurve = true
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
        
        if closed {
            dashedConnectors.addLine(to: interpolationPoints[0])
            dashedConnectors.close()
        }
        
        let dashedPattern : [CGFloat] = [3, 3, 3, 3]
        dashedConnectors.setLineDash(dashedPattern, count: 4, phase: 0.0)
        dashedConnectors.lineWidth = 1
        UIColor(colorLiteralRed: 0.4, green: 0.4, blue: 0.4, alpha: 1).setStroke()
        dashedConnectors.stroke()
        
        // Interpolation points drawing
        for point in interpolationPoints {
            let pointPath = UIBezierPath(ovalIn: CGRect(x:point.x - 4, y:point.y - 4, width: 8, height: 8))
            UIColor.red.setFill()
            pointPath.fill()
        }
        
        guard showCurve == true else { return }
        
        // Curve drawing
        let path = UIBezierPath()
        let controlPoints = path.interpolatePointsWithHermite(interpolationPoints: interpolationPoints, alpha: interpolationAlpha, closed: closed)
        
        lineColor.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
        
        guard showHandles == true else { return }
        
        // Drawing control points
        for controlPoint in controlPoints {
            let pointPath = UIBezierPath(ovalIn: CGRect(x:controlPoint.x - 2, y: controlPoint.y - 2, width: 4, height: 4))
            UIColor.blue.setFill()
            pointPath.fill()
        }
        
        // Drawing handles to connect control points
        
        // To iterate on controlPoints
        var jj = 0
        while jj < controlPoints.count {
            // To iterate on interpolationPoints
            let ii = jj / 2
            
            let handle = UIBezierPath()
            if jj % 2 == 0 {
                handle.move(to: interpolationPoints[ii])
                handle.addLine(to: controlPoints[jj])
            } else {
                handle.move(to: controlPoints[jj])
                if interpolationPoints.count > ii + 1 {
                    handle.addLine(to: interpolationPoints[ii + 1])
                } else {
                    handle.addLine(to: interpolationPoints[0])
                }
            }
            handle.lineWidth = 1 / UIScreen.main.scale
            UIColor(colorLiteralRed: 0.4, green: 0.4, blue: 0.4, alpha: 1).setStroke()
            handle.stroke()
            
            jj = jj + 1
        }
    }
}

