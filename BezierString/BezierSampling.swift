//
//  BezierSampling.swift
//
//  Created by Luka on 22. 11. 14.
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
import Accelerate

extension UIBezierPath {
	
	/**
	Samples the bezier path 
	
	:param: accuracy maximum distance between two neighbouring points, maximum distance between a midpoint and a sampled point
	
	:returns: points along the path with given accuracy
	*/
	func sample(accuracy: CGFloat = 1) -> [CGPoint] {

		// sampling context dimensions
		let pathBounds = CGPathGetPathBoundingBox(self.CGPath)
		
		let scale = min(1, sqrt(2048/(pathBounds.width * pathBounds.height)))
		
		let d: UInt = 4	// margin
		let w: UInt = UInt(ceil(pathBounds.width  * scale/2)*2) + 2*d
		let h: UInt = UInt(ceil(pathBounds.height * scale/2)*2) + 2*d
		
		// shape layer
		let shape = CAShapeLayer()
		shape.path = self.CGPath
		shape.fillColor = UIColor.clearColor().CGColor
		shape.strokeColor = UIColor.blackColor().CGColor
		shape.lineCap = kCALineCapRound
		shape.lineWidth = 1/scale/2
		
		// context
		let colorSpace = CGColorSpaceCreateDeviceGray()
		let ctx = CGBitmapContextCreate(nil, w, h, 8, w, colorSpace, CGBitmapInfo(CGImageAlphaInfo.Only.rawValue))
		
		CGContextTranslateCTM(ctx, CGFloat(d), CGFloat(d))
		CGContextScaleCTM(ctx, scale, scale)
		CGContextTranslateCTM(ctx, -pathBounds.origin.x, -pathBounds.origin.y)
		
		// data
		let data  = UnsafeMutablePointer<UInt8>(CGBitmapContextGetData(ctx))
		let fData = UnsafeMutablePointer<Float>(malloc(UInt(sizeof(Float))*w*h)) // float data
		
		// get a distance between 2 points, ~5% of the total length apart, to get an estimation for the number of samples required
		
		var maxAmp:Float = 0
		var idx1: vDSP_Length = 0, idx2: vDSP_Length = 0
		
		shape.strokeStart = 0 - 0.0002 // TODO: sampling in the middle of the path might be a better option, test
		shape.strokeEnd   = 0 + 0.0002
		shape.renderInContext(ctx)
		
		// get index of the brightest pixel and calculate position
		vDSP_vfltu8(data, 1, fData, 1, w*h)
		vDSP_maxvi(fData, 1, &maxAmp, &idx1, w*h)
		vDSP_vclr(UnsafeMutablePointer<Float>(data), 1, w*h/UInt(sizeof(Float)/sizeof(UInt8))) // size is divisible by 4
		
		shape.strokeStart = 0.05 - 0.0002
		shape.strokeEnd   = 0.05 + 0.0002
		shape.renderInContext(ctx)
		
		vDSP_vfltu8(data, 1, fData, 1, w*h)
		vDSP_maxvi(fData, 1, &maxAmp, &idx2, w*h)

		let CGPointFromIndex = { (idx: vDSP_Length) -> CGPoint in
			let x = Int(idx)%Int(w)-Int(d)
			let y = Int(h)-1-Int(idx)/Int(w)-Int(d)
			return CGPointMake(CGFloat(x)/scale, CGFloat(y)/scale)
		}
		
		let p1 = CGPointFromIndex(idx1)
		let p2 = CGPointFromIndex(idx2)
		
		let dist = p1.distanceTo(p2)
		let count = max(3, ceil(dist / 0.05 / 24)) // at least 3 samples or a sample every ~ 24px

		// curve sampling
		let sample = { (t: Double) -> CGPoint in
			
			shape.strokeStart = CGFloat(t)/(count-1) - CGFloat(0.001)
			shape.strokeEnd   = CGFloat(t)/(count-1) + CGFloat(0.001)
			
			vDSP_vclr(UnsafeMutablePointer<Float>(data), 1, w*h/UInt(sizeof(Float)/sizeof(UInt8)))
			
			shape.lineWidth = 1/scale/2
			shape.renderInContext(ctx)
			
			var maxAmp: Float = 0
			var idx: vDSP_Length = 0
			
			vDSP_vfltu8(data, 1, fData, 1, w*h)
			vDSP_maxvi(fData, 1, &maxAmp, &idx, w*h)
			
			// rough approximation
			let point = pathBounds.origin + CGPointFromIndex(idx)
			
			// finer sampling
			var subScale = CGFloat(min(w, h))/2.0

			shape.strokeStart = CGFloat(t)/(count-1) - CGFloat(0.0001)
			shape.strokeEnd   = CGFloat(t)/(count-1) + CGFloat(0.0001)
			
			maxAmp = 0.0
			
			let centerScaled = CGPointMake(CGFloat(w)/2.0 - CGFloat(d), CGFloat(h)/2.0 - CGFloat(d)) / scale
			
			while maxAmp == 0.0 {
				
				CGContextSaveGState(ctx)
				
				vDSP_vclr(UnsafeMutablePointer<Float>(data), 1, w*h/UInt(sizeof(Float)/sizeof(UInt8)))
				
				// center the brightest pixel and zoom in
				
				CGContextTranslateCTM(ctx,
					pathBounds.origin.x - point.x*subScale + centerScaled.x,
					pathBounds.origin.y - point.y*subScale + centerScaled.y)
				CGContextScaleCTM(ctx, subScale, subScale)
				
				shape.lineWidth = 1/scale/subScale
				shape.renderInContext(ctx)
				
				vDSP_vfltu8(data, 1, fData, 1, w*h)
				vDSP_maxvi(fData, 1, &maxAmp, &idx, w*h)
				
				CGContextRestoreGState(ctx)
				
				// if a pixel was not found, zoom out a bit and try again
				if maxAmp == 0 {
					subScale /= 1.5
				}
			}
				
			return point + (CGPointFromIndex(idx) - centerScaled) / subScale
		}
		
		let sampleRequired = { (values: [CGPoint], i: Int) -> Bool in
			
			if i<2 { return false }
			
			let l = values[i-2]
			let m = values[i-1]
			let r = values[i-0]
			
			let distLM = m.distanceTo(l)
			let distMR = m.distanceTo(r)
			
			let s = (1/(2*(distLM+distMR)))
			let p = s * (distMR * (l+m) + distLM * (m+r))
			
			let distPM = m.distanceTo(p)

			return distPM >= accuracy && distLM >= accuracy && distMR >= accuracy || distMR / distLM > 2.75
		}

		let samples = (0..<Int(count)).generateSamples(sample, newSampleRequired: sampleRequired)
		
		free(fData)
		
		return samples
	}
}