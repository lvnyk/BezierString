//
//  BezierString.swift
//
//  Created by Luka on 23. 11. 14.
//  Copyright (c) 2014 lvnyk. All rights reserved.
//

import UIKit

class BezierString {
	
	let bezierPath: UIBezierPath
	let samples: [(point: CGPoint, length: CGFloat, angle: CGFloat)]
	
	init( bezierPath: UIBezierPath ) {
		
		self.bezierPath = bezierPath
		
		var prevPoint = (point: CGPointZero, length: CGFloat(0.0), angle: CGFloat(0.0))
		var firstSample = true
		self.samples = bezierPath.sample().map {
			(p) -> (point: CGPoint, length: CGFloat, angle: CGFloat) in
			
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

				var length = length - (samples[i-1].length + len1)

				let deltaAngle = arcFi(samples[i+1].angle, samples[i].angle)
				let orientation = (compareAngles(samples[i+1].angle-CGFloat.Pi/2, samples[i+1].angle, samples[i].angle) > 0 ? -1 : 1)
				
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
	
	:param: string NSAttributed string to be drawn on the context
	:param: context context to be drawn on
	:param: align text alignment, default is .Center
	:param: yOffset offset above or below the centerline in units of line height, default is 0
	*/
	func drawAttributedString(string: NSAttributedString, toContext context:CGContextRef, align alignment:NSTextAlignment = .Center, yOffset:CGFloat = 0) {
		
		CGContextSaveGState(context)
		
		CGContextSetAllowsFontSmoothing(context, true)
		CGContextSetShouldSmoothFonts(context, true)
		
		CGContextSetAllowsFontSubpixelPositioning(context, true)
		CGContextSetShouldSubpixelPositionFonts(context, true)
		
		CGContextSetAllowsFontSubpixelQuantization(context, true)
		CGContextSetShouldSubpixelQuantizeFonts(context, true)
		
		CGContextSetAllowsAntialiasing(context, true)
		CGContextSetShouldAntialias(context, true)
		
		CGContextSetInterpolationQuality(context, kCGInterpolationHigh)
			
		var linePos: CGFloat = 0
		var charSpacing: CGFloat = 0
		var align = alignment
		
		let stringLength = string.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesFontLeading, context: nil).width
		let spaceRemaining = samples.last!.length - stringLength
		if spaceRemaining < 0 {
			align = NSTextAlignment.Justified
		}
		
		switch align {
		case .Center:
			linePos = spaceRemaining / 2
		case .Right:
			linePos = spaceRemaining
		case .Justified:
			charSpacing = spaceRemaining / CGFloat(max(2,string.length-1))
			if string.length==1 {
				linePos = charSpacing
			}
			
		default: break
		}
		
		for var i=0; i<string.length; i++ {
			
			let s = string.attributedSubstringFromRange(NSMakeRange(i, 1))
			let size = s.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: NSStringDrawingOptions.UsesFontLeading, context: nil)
			
			let position = self.pointAtLength(linePos + size.width/2)
			let rotation = self.angleAtLength(linePos + size.width/2)
			
			let textTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1, -1),
				CGAffineTransformConcat(
					CGAffineTransformMakeTranslation(-size.width/2, size.origin.y + size.height*(0.5+yOffset)),
					CGAffineTransformConcat(
						CGAffineTransformMakeRotation(rotation),
						CGAffineTransformMakeTranslation(position.x, position.y)
					) ) )
			
			CGContextSetTextMatrix(context, textTransform)
			
			let line = CTLineCreateWithAttributedString(s)
			CTLineDraw(line, context)
			
			linePos += charSpacing + size.size.width
		}
		
		CGContextRestoreGState(context)
	}

	/**
	Generates an image containing the string following the bezier path
	
	:param: string NSAttributed string to be rendered
	:param: imageSize size of the image to be returned. If nil, twice the size to the center of the path is used
	:param: align text alignment, default is .Center
	:param: yOffset offset above or below the centerline in units of line height, default is 0
	
	:returns: UIImage containing the provided string following the bezier path
	*/
	func imageWithAttributedString(string: NSAttributedString, imageSize: CGSize? = nil, align alignment:NSTextAlignment = .Center, yOffset:CGFloat = 0) -> UIImage? {
		
		let imageSize = imageSize ?? self.sizeThatFits()
		
		if imageSize.width <= 0 || imageSize.height <= 0 {
			return nil
		}
		
		UIGraphicsBeginImageContextWithOptions(imageSize, false, 0)
		
		self.drawAttributedString(string, toContext: UIGraphicsGetCurrentContext(), align: alignment, yOffset: yOffset)
		
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
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func drawRect(rect: CGRect) {
		if let bezierString = bezierString {
			bezierString.drawAttributedString(self.attributedText, toContext: UIGraphicsGetCurrentContext(), align: _textAlignment, yOffset: textPathOffset)
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