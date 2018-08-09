//
//  BezierString.swift
//
//  Created by Luka on 23. 11. 14.
//  Copyright (c) 2014 lvnyk
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import UIKit

// MARK: Rendering

/// Text rendering extension
extension Bezier {
    
    /**
     Adds the string to the provided context, following the bezier path
     
     - parameter string: NSAttributed string to be drawn on the context
     - parameter context: context to be drawn on
     - parameter align: text alignment, default is .Center
     - parameter y: y offset above or below the centerline in units of line height, default is 0
     */
    func draw(attributed string: NSAttributedString,
              to context: CGContext,
              align alignment: NSTextAlignment = .center,
              y offset: CGFloat = 0, fitWidth: Bool = false) {
        
        let pathLength = self.length()
        
        context.saveGState()
        
        context.setAllowsFontSmoothing(true)
        context.setShouldSmoothFonts(true)
        
        context.setAllowsFontSubpixelPositioning(true)
        context.setShouldSubpixelPositionFonts(true)
        
        context.setAllowsFontSubpixelQuantization(true)
        context.setShouldSubpixelQuantizeFonts(true)
        
        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        
        context.interpolationQuality = CGInterpolationQuality.high
        
        let line = CTLineCreateWithAttributedString(string)
        let runs = CTLineGetGlyphRuns(line)
        
        var linePos: CGFloat = 0
        let charSpacing: CGFloat
        let align: NSTextAlignment
        
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        let stringWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
        let height = ascent - descent * 2 + leading * 2
        
        let scale: CGFloat
        let spaceRemaining: CGFloat
        if fitWidth && pathLength < stringWidth {
            spaceRemaining = 0
            scale = min(1, pathLength / stringWidth)
        } else {
            spaceRemaining = pathLength - stringWidth
            scale = 1
        }
        
        if spaceRemaining < 0 {
            align = .justified
        } else {
            align = alignment
        }
        
        switch align {
        case .center:
            linePos = spaceRemaining / 2
            charSpacing = 0
        case .right:
            linePos = spaceRemaining
            charSpacing = 0
        case .justified:
            charSpacing = spaceRemaining / CGFloat(max(2,string.length-1))
            if string.length==1 {
                linePos = charSpacing
            }
        default:
            charSpacing = 0
        }
        
        var glyphOffset:CGFloat = 0
        
        for r in 0..<CFArrayGetCount(runs) {
            
            let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), to: CTRun.self)
            let runCount = CTRunGetGlyphCount(run)
            
            let kern = (CTRunGetAttributes(run) as? [NSAttributedString.Key:Any])?[NSAttributedString.Key.kern] as? CGFloat ?? 0
            
            var advances = Array(repeating: CGSize.zero, count: runCount)
            CTRunGetAdvances(run, CFRange(location: 0, length: runCount), &advances)
            
            for (i, advance) in advances.enumerated() {
                
                let width = advance.width-kern
                let length = linePos + width/2
                
                guard let p = self.properties(at: length) else { break }
                
                let textTransform = CGAffineTransform(scaleX: 1, y: -1)
                    .concatenating(CGAffineTransform(translationX: -glyphOffset-width/2/scale, y: height*(0.5+offset))
                        .concatenating(CGAffineTransform(scaleX: scale, y: scale)
                            .concatenating(CGAffineTransform(rotationAngle: p.normal)
                                .concatenating(CGAffineTransform(translationX: p.position.x, y: p.position.y)))))
                
                context.textMatrix = textTransform
                
                CTRunDraw(run, context, CFRange(location: i, length: 1))
                
                glyphOffset += width + kern
                linePos += (charSpacing + width + kern) * scale
            }
        }
        
        context.restoreGState()
    }
    
    /**
     Generates an image containing the string following the bezier path
     
     - parameter string: NSAttributed string to be rendered
     - parameter imageSize: size of the image to be returned. If nil, twice the size to the center of the path is used
     - parameter align: text alignment, default is .Center
     - parameter y: offset above or below the centerline in units of line height, default is 0
     
     - returns: UIImage containing the provided string following the bezier path
     */
    func image(withAttributed string: NSAttributedString,
               size imageSize: CGSize? = nil,
               align alignment: NSTextAlignment = .center,
               y offset: CGFloat = 0, fitWidth: Bool = false) -> UIImage? {
        
        let imageSize = imageSize ?? self.sizeThatFits()
        
        if imageSize.width <= 0 || imageSize.height <= 0 {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        self.draw(attributed: string, to: ctx, align: alignment, y: offset, fitWidth: fitWidth)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        
        return image
    }
    
    /// something approximate ... assume the path is centered and has enough space on top and left to be able to accomodate the text
    func sizeThatFits() -> CGSize {
        let bounds = path.boundingBoxOfPath
        let imageSize = CGSize(width: bounds.midX*2, height: bounds.midY*2)
        
        return imageSize
    }
}

// MARK: - Label

class UIBezierLabel: UILabel {
    
    /// set the CGPath, Bezier gets automatically generated
    var bezierPath: CGPath? {
        get {
            return bezier?.path
        }
        set {
            if let path = newValue {
                bezier = Bezier(path: path)
            } else {
                bezier = nil
            }
        }
    }
    
    var bezier: Bezier? {
        didSet {
            self.numberOfLines = 1
        }
    }
    
    /// y offset offset above or below the centerline in units of line height, default is 0
    var textPathOffset: CGFloat = 0
    
    
    // .Justify doesn't work on UILabels
    fileprivate var _textAlignment: NSTextAlignment = .left
    override var textAlignment: NSTextAlignment {
        willSet {
            _textAlignment = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        if let bezier = bezier, let string = self.attributedText, let ctx = UIGraphicsGetCurrentContext() {
            bezier.draw(attributed: string, to: ctx, align: _textAlignment, y: textPathOffset, fitWidth: adjustsFontSizeToFitWidth)
        } else {
            super.draw(rect)
        }
        
    }
    
    /// works according to the dimensions of the bezier path, not the text
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        if let bezier = bezier {
            return bezier.sizeThatFits()
        }
        
        return super.sizeThatFits(size)
    }
}
