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

class BezierString {
	
	let bezierPath: UIBezierPath
	let samples: [(point: CGPoint, length: CGFloat, angle: CGFloat)]
	
	init( bezierPath: UIBezierPath ) {
		
		self.bezierPath = bezierPath
		
		var prevPoint = (point: CGPointZero, length: CGFloat(0.0), angle: CGFloat(0.0))
		var firstSample = true
		self.samples = bezierPath.sample().map {
			p -> (point: CGPoint, length: CGFloat, angle: CGFloat) in
			
			if firstSample {
				prevPoint.point = p
				firstSample = false
			}
			prevPoint.length += p.distanceTo(prevPoint.point)
			prevPoint.angle = atan2(p.y-prevPoint.point.y, p.x-prevPoint.point.x)
			prevPoint.point = p
			
			return prevPoint
		}
	}
	
	// MARK: -
	
	private func angleAtLength(length: CGFloat) -> CGFloat {
		
		for var i=1; i<samples.count; i++ {
			
			if length < samples[i].length || i==samples.count-1 {
				
				if length < samples[i-1].length + (samples[i].length-samples[i-1].length)/2 { i-- }
				
				if i == 0 { return samples[1].angle }
				if i >= samples.count-1 { return samples.last!.angle }

				let len1 = (samples[i].length-samples[i-1].length)/2
				let len2 = (samples[i+1].length-samples[i].length)/2

				let length = length - (samples[i-1].length + len1)

				let deltaAngle = arcFi(samples[i+1].angle, fi2: samples[i].angle)
				let orientation = compareAngles(samples[i+1].angle-CGFloat.Pi/2, fi1: samples[i+1].angle, fi2: samples[i].angle) > 0 ? -1 : 1
				
				return samples[i].angle + deltaAngle * CGFloat(orientation) * (min(1, length/len1) + max(0, (length-len1)/len2)) / 2
			}
		}
		
		return 0
	}
	
	private func pointAtLength(length: CGFloat) -> CGPoint {
		for var i=1; i<samples.count; i++ {
			if length < samples[i].length || i==samples.count-1 {
				let length = length - samples[i-1].length
				
				return samples[i-1].point + (samples[i].point-samples[i-1].point) * (length / (samples[i].length - samples[i-1].length))
			}
		}
		
		return CGPointZero
	}
	
	
	// MARK: -
	
	/**
	Adds the string to the provided context, following the bezier path
	
	- parameter string: NSAttributed string to be drawn on the context
	- parameter context: context to be drawn on
	- parameter align: text alignment, default is .Center
	- parameter yOffset: offset above or below the centerline in units of line height, default is 0
	*/
	func drawAttributedString(string: NSAttributedString, toContext context:CGContextRef, align alignment:NSTextAlignment = .Center, yOffset:CGFloat = 0, fitWidth:Bool = false) {
		
		guard let lastSample = samples.last else { return }
		
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
		
		let ascent = UnsafeMutablePointer<CGFloat>(malloc((sizeof(CGFloat)*3)))
		let stringWidth = CGFloat(CTLineGetTypographicBounds(line, &ascent[0], &ascent[1], &ascent[2]))
		let height = ascent[0]-ascent[1]*2+ascent[2]*2
		free(ascent)
		
		let scale: CGFloat
		let spaceRemaining: CGFloat
		if fitWidth && lastSample.length < stringWidth {
			spaceRemaining = 0
			scale = min(1, lastSample.length / stringWidth)
		} else {
			spaceRemaining = lastSample.length - stringWidth
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
	
			let run = unsafeBitCast(CFArrayGetValueAtIndex(runs, r), CTRunRef.self)
			let runCount = CTRunGetGlyphCount(run)
			
			let advances = UnsafeMutablePointer<CGSize>(malloc((sizeof(CGSize))*runCount))
			
			CTRunGetAdvances(run, CFRangeMake(0, runCount), advances)
			
			for var i=0; i<runCount; i++ {
			
				let position = self.pointAtLength(linePos + advances[i].width/2)
				let rotation = self.angleAtLength(linePos + advances[i].width/2)
				
				let textTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, -1),
					CGAffineTransformConcat(
						CGAffineTransformMakeTranslation(-glyphOffset-advances[i].width/2/scale, height*(0.5+yOffset)),
						CGAffineTransformConcat(
							CGAffineTransformMakeScale(scale, scale),
							CGAffineTransformConcat(
								CGAffineTransformMakeRotation(rotation),
								CGAffineTransformMakeTranslation(position.x, position.y)
							) ) ) )
				
				CGContextSetTextMatrix(context, textTransform)
				
				CTRunDraw(run, context, CFRangeMake(i, 1))
				
				glyphOffset += advances[i].width
				linePos += (charSpacing + advances[i].width) * scale
			}
			
			free(advances)
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
		let bounds = CGPathGetPathBoundingBox(bezierPath.CGPath)
		let imageSize = CGSizeMake(bounds.midX*2, bounds.midY*2)
		
		return imageSize
	}
}

class UIBezierLabel: UILabel {
	
	/// set the UIBezierPath, BezierString gets automatically generated
	var bezierPath: UIBezierPath? {
		get {
			return bezierString?.bezierPath
		}
		set {
			if let path = newValue {
				bezierString = BezierString(bezierPath: path)
			} else {
				bezierString = nil
			}
		}
	}
	
	var bezierString: BezierString? {
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
		if let bezierString = bezierString, text = self.attributedText, ctx = UIGraphicsGetCurrentContext() {
			bezierString.drawAttributedString(text, toContext: ctx, align: _textAlignment, yOffset: textPathOffset, fitWidth: adjustsFontSizeToFitWidth)
		} else {
			super.drawRect(rect)
		}
	}
	
	/// works according to the dimensions of the bezier path, not the text
	override func sizeThatFits(size: CGSize) -> CGSize {
		if let bezierString = bezierString {
			return bezierString.sizeThatFits()
		}
		
		return super.sizeThatFits(size)
	}
}