import UIKit

extension UIColor {
    public class var clientelingBlue: UIColor {
        return UIColor.colorWithRGB(rgbValue: 0x0072BC)
    }
    
    public class var clientelingGray: UIColor {
        return UIColor.colorWithRGB(rgbValue: 0x5C6970)
    }
    
    public class var clientelingLightGray: UIColor {
        return UIColor.colorWithRGB(rgbValue: 0xF0F0F0)
    }
    
    
    class func getColor(color: UInt) -> UIColor {
        return UIColor.colorWithRGB(rgbValue: color)
    }
    
    class func colorWithRGB(rgbValue : UInt, alpha : CGFloat = 1.0) -> UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255
        let blue = CGFloat(rgbValue & 0xFF) / 255
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    class func hexStringToUIColor (hex:String) -> UIColor? {
        var hexString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (hexString.hasPrefix("#")) {
            hexString.remove(at: hexString.startIndex)
            
            if hexString.characters.count == 6 {
                var rgbValue:UInt32 = 0
                Scanner(string: hexString).scanHexInt32(&rgbValue)
                
                return UIColor(
                    red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                    green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                    blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                    alpha: CGFloat(1.0)
                )
            }
        }
        return nil
    }
}

extension String {
    public var color : UIColor {
        if let parsedColor = UIColor.hexStringToUIColor(hex: self) {
            return parsedColor
        }
        return UIColor.red
    }
}
