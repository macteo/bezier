//: **MathJax** some formulas

//#-hidden-code
import UIKit
import PlaygroundSupport

public class MathController: UIViewController {
    
    public func loadMathJaxDemo(){
        NSLog("Standard demo loaded");
        
        let htmlView = UIWebView(frame: self.view.frame);
        let path = Bundle.main.path(forResource: "sample", ofType: "html", inDirectory: "MathJax/test")
        htmlView.loadRequest(URLRequest(url: URL(fileURLWithPath:path!)));
        htmlView.scalesPageToFit = true;
        htmlView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.view.autoresizesSubviews = true;
        
        self.view.addSubview(htmlView);
    }
}

let mathController = MathController()

PlaygroundPage.current.liveView = mathController

mathController.loadMathJaxDemo()
//#-end-hidden-code

//#-editable-code

let sqrt = "sqrt(2)"

//#-end-editable-code