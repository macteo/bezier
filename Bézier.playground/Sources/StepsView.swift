import UIKit

public protocol Stepper {
    var step : Int { get set }
}

let titleFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title1)

public class StepsView : UIView {
    let forwardButton = UIButton()
    let backButton = UIButton()
    let stepLabel = UILabel()
    
    let padding : CGFloat = 10
    let buttonSize : CGFloat = 44
    
    let blue = "#4990E2".color
    
    var stepsCount = 8
    var currentStep = 1
    
    var delegate : Stepper?
    var enabled : Bool = true
    
    let titleMonospacedNumbersFontDescriptor = titleFontDescriptor.addingAttributes(
        [
            UIFontDescriptorFeatureSettingsAttribute: [
                [
                    UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                    UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
                ]
            ]
        ])
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        backgroundColor = .white
        
        backButton.frame = CGRect(x: padding, y: padding, width: buttonSize, height: buttonSize)
        forwardButton.frame = CGRect(x: frame.size.width - padding - buttonSize, y: padding, width: buttonSize, height: buttonSize)
        
        backButton.autoresizingMask = .flexibleRightMargin
        forwardButton.autoresizingMask = .flexibleLeftMargin
        
        let backArrow = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysTemplate)
        backButton.setImage(backArrow, for: .normal)
        backButton.tintColor = blue
        backButton.isEnabled = false
        
        let forwardArrow = UIImage(named: "forward_arrow")?.withRenderingMode(.alwaysTemplate)
        forwardButton.setImage(forwardArrow, for: .normal)
        forwardButton.tintColor = blue
        
        addSubview(backButton)
        addSubview(forwardButton)
        
        backButton.addTarget(self, action: #selector(backward), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forward), for: .touchUpInside)
        
        stepLabel.frame = CGRect(x: padding * 2 + buttonSize, y: padding, width: frame.size.width - padding * 4 - buttonSize * 2, height: buttonSize)
        stepLabel.autoresizingMask = .flexibleWidth
        addSubview(stepLabel)
        
        stepLabel.text = "Step: 1"
        stepLabel.textColor = blue
        stepLabel.textAlignment = .center
        let stepFont = UIFont(descriptor: titleMonospacedNumbersFontDescriptor, size: 0.0)
        stepLabel.font = stepFont
    }
    
    func forward() {
        guard enabled else { return }
        guard currentStep < stepsCount else {
            currentStep = 1
            delegate?.step = currentStep
            update()
            return
        }
        currentStep = currentStep + 1
        delegate?.step = currentStep
        update()
    }
    
    func backward() {
        guard enabled else { return }
        guard currentStep > 1 else {
            currentStep = stepsCount
            delegate?.step = currentStep
            update()
            return
        }
        currentStep = currentStep - 1
        delegate?.step = currentStep
        update()
    }
    
    func update() {
        if currentStep == 1 {
            forwardButton.isEnabled = true
            backButton.isEnabled = false
        } else if currentStep == stepsCount {
            forwardButton.isEnabled = false
            backButton.isEnabled = true
        } else {
            forwardButton.isEnabled = true
            backButton.isEnabled = true
        }
        stepLabel.text = "Step: \(currentStep)"
    }
}
