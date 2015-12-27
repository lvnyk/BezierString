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
	- parameter yOffset: offset above or below the centerline in units of line height, default is 0
	*/
	func drawAttributedString(string: NSAttributedString, toContext context:CGContext, align alignment:NSTextAlignment = .Center, yOffset:CGFloat = 0, fitWidth:Bool = false) {
		
		let pathLength = self.length()
		
		CGContextSaveGState(context)
		
		CGContextSetAllowsFontSmoothing(context, true)
		CGContextSetShouldSmoothFonts(context, true)
		
		CGContextSetAllowsFontSubpixelPositioning(context, true)
		CGContextSetShouldSubpixelPositionFonts(context, true)
		
		CGContextSetAllowsFontSubpixelQuantization(context, true)
		CGContextSetShouldSubpixelQuantizeFonts(context, true)
		
		CGContextSetAllowsAntialiasing(context, true)
		CGContextSetShouldAntialias(context, true)
		
		CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
		
		let line = CTLineCreateWithAttributedString(string)
		let runs = CTLineGetGlyphRuns(line)
		
		var linePos: CGFloat = 0
		let charSpacing: CGFloat
		let align: NSTextAlignment
		
		var ascent = Array(count: 3, repeatedValue: CGFloat(0))
		let stringWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent[0], &ascent[1], &ascent[2]))
		let height = ascent[0]-ascent[1]*2+ascent[2]*2
		
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
			align = NSTextAlignment.Justified
		} else {
			align = alignment
		}
		
		switch align {
		case .Center:
			linePos = spaceRemaining / 2
			charSpacing = 0
		case .Right:
			linePos = spaceRemaining
			charSpacing = 0
		case .Justified:
			charSpacing = spaceRemaining / CGFloat(max(2,string.length-1))
			if string.length==1 {
				linePos = charSpacing
			}
		default:
			charSpacing = 0
		}
		
		var glyphOffset:CGFloat = 0
		
		for r in 0..<CFArrayGetCount(runs) {
			
			let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), CTRun.self)
			let runCount = CTRunGetGlyphCount(run)
			
			var advances = Array(count: runCount, repeatedValue: CGSizeZero)
			CTRunGetAdvances(run, CFRangeMake(0, runCount), &advances)
			
			for (i, advance) in advances.enumerate() {
				
				let width = advance.width
				let length = linePos + width/2
				
				guard let p = self.propertiesAt(length) else { break }
				
				let textTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, -1),
					CGAffineTransformConcat(
						CGAffineTransformMakeTranslation(-glyphOffset-width/2/scale, height*(0.5+yOffset)),
						CGAffineTransformConcat(
							CGAffineTransformMakeScale(scale, scale),
							CGAffineTransformConcat(
								CGAffineTransformMakeRotation(p.normal),
								CGAffineTransformMakeTranslation(p.position.x, p.position.y)
							) ) ) )
				
				CGContextSetTextMatrix(context, textTransform)
				
				CTRunDraw(run, context, CFRangeMake(i, 1))
				
				glyphOffset += width
				linePos += (charSpacing + width) * scale
			}
		}
		
		CGContextRestoreGState(context)
	}
	
	/**
	Generates an image containing the string following the bezier path
	
	- parameter string: NSAttributed string to be rendered
	- parameter imageSize: size of the image to be returned. If nil, twice the size to the center of the path is used
	- parameter align: text alignment, default is .Center
	- parameter yOffset: offset above or below the centerline in units of line height, default is 0
	
	- returns: UIImage containing the provided string following the bezier path
	*/
	func imageWithAttributedString(string: NSAttributedString, imageSize: CGSize? = nil, align alignment: NSTextAlignment = .Center, yOffset:CGFloat = 0, fitWidth: Bool = false) -> UIImage? {
		
		let imageSize = imageSize ?? self.sizeThatFits()
		
		if imageSize.width <= 0 || imageSize.height <= 0 {
			return nil
		}
		
		UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
		
		guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
		self.drawAttributedString(string, toContext: ctx, align: alignment, yOffset: yOffset, fitWidth: fitWidth)
		
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return image
	}
	
	/// something approximate ... assume the path is centered and has enough space on top and left to be able to accomodate the text
	func sizeThatFits() -> CGSize {
		let bounds = CGPathGetPathBoundingBox(path)
		let imageSize = CGSizeMake(bounds.midX*2, bounds.midY*2)
		
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
	private var _textAlignment: NSTextAlignment = NSTextAlignment.Left
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
	
	override func drawRect(rect: CGRect) {
		if let bezier = bezier, text = self.attributedText, ctx = UIGraphicsGetCurrentContext() {
			bezier.drawAttributedString(text, toContext: ctx, align: _textAlignment, yOffset: textPathOffset, fitWidth: adjustsFontSizeToFitWidth)
		} else {
			super.drawRect(rect)
		}
	}
	
	/// works according to the dimensions of the bezier path, not the text
	override func sizeThatFits(size: CGSize) -> CGSize {
		if let bezier = bezier {
			return bezier.sizeThatFits()
		}
		
		return super.sizeThatFits(size)
	}
}