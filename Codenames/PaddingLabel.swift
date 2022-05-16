//
//  PaddingLabel.swift
//  Codenames
//
//  Created by Tyler Martin on 5/29/20.
//  Copyright © 2020 Tyler Martin. All rights reserved.
//

import UIKit

/// Padding label class
@IBDesignable class PaddingLabel: UILabel {
    
    /*@IBInspectable var topInset: CGFloat = 3.0
     @IBInspectable var bottomInset: CGFloat = 3.0
     @IBInspectable var leftInset: CGFloat = 4.0
     @IBInspectable var rightInset: CGFloat = 4.0
     
     override func drawText(in rect: CGRect) {
     let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
     super.drawText(in: rect.inset(by: insets))
     }
     
     override var intrinsicContentSize: CGSize {
     let size = super.intrinsicContentSize
     return CGSize(width: size.width + leftInset + rightInset,
     height: size.height + topInset + bottomInset)
     }*/
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
}

/// Padding Label extension
extension PaddingLabel {
    @IBInspectable
    var leftTextInset: CGFloat {
        set { textInsets.left = newValue }
        get { return textInsets.left }
    }
    
    @IBInspectable
    var rightTextInset: CGFloat {
        set { textInsets.right = newValue }
        get { return textInsets.right }
    }
    
    @IBInspectable
    var topTextInset: CGFloat {
        set { textInsets.top = newValue }
        get { return textInsets.top }
    }
    
    @IBInspectable
    var bottomTextInset: CGFloat {
        set { textInsets.bottom = newValue }
        get { return textInsets.bottom }
    }
}
