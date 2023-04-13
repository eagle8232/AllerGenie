//
//  CirclePercentageView.swift
//  FoodAllergenScanApp
//
//  Created by Vusal Nuriyev on 4/6/23.
//

import UIKit


protocol CirclePercentageViewDelegate {
    func matchResult(_ result: ProductHealthiness)
}

class CirclePercentageView: UIView {
    var percentage: CGFloat = 0 {
        didSet {
            updateLabel()
            setNeedsDisplay()
        }
    }
    
    private let textLabel = UILabel()
    
    var delegate: CirclePercentageViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        addSubview(textLabel)
    }
    
    private func fillColorAndText(forPercentage percentage: CGFloat) -> (UIColor, String) {
        if percentage > 70 {
            delegate?.matchResult(.healthy)
            return (.green, "Excellent Match")
        } else if percentage > 40 {
            delegate?.matchResult(.notRecommended)
            return (UIColor(red: 1, green: 0.5, blue: 0, alpha: 1), "Average Match")
        } else if percentage < 40 {
            delegate?.matchResult(.avoid)
            return (.red, "Avoid")
        } else {
            delegate?.matchResult(.not_found)
            return (.gray, "Not Found")
        }
    }
    
    private func updateLabel() {
        let (fillColor, text) = fillColorAndText(forPercentage: percentage)
        textLabel.text = text
        textLabel.textColor = fillColor
        textLabel.font = UIFont.systemFont(ofSize: bounds.width * 0.1)
        textLabel.sizeToFit()
        textLabel.frame.origin.x = bounds.maxX + bounds.width * 0.1
        textLabel.frame.origin.y = bounds.midY - textLabel.bounds.height / 2
    }
    
    override func draw(_ rect: CGRect) {
        let circlePath = UIBezierPath(ovalIn: rect)
        let (fillColor, _) = fillColorAndText(forPercentage: percentage)
        fillColor.setFill()
        circlePath.fill()
        
        let percentageText = "\(Int(percentage))%"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: rect.width * 0.3),
            .foregroundColor: UIColor.white
        ]
        let textSize = percentageText.size(withAttributes: attributes)
        let textRect = CGRect(x: (rect.width - textSize.width) / 2,
                              y: (rect.height - textSize.height) / 2,
                              width: textSize.width,
                              height: textSize.height)
        percentageText.draw(in: textRect, withAttributes: attributes)
    }
}
