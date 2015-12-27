//
//  Geometry.swift
//
//  Created by Luka on 27. 08. 14.
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

// MARK: - calculations
// MARK: CGPoint
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPointMake(lhs.x+rhs.x, lhs.y+rhs.y)
}

func +=(inout lhs: CGPoint, rhs: CGPoint) {
	lhs.x += rhs.x
	lhs.y += rhs.y
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPointMake(lhs.x-rhs.x, lhs.y-rhs.y)
}

func -=(inout lhs: CGPoint, rhs: CGPoint) {
	lhs.x -= rhs.x
	lhs.y -= rhs.y
}

func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
	return CGPointMake(lhs.x*rhs, lhs.y*rhs)
}

func *=(inout lhs: CGPoint, rhs: CGFloat) {
	lhs.x *= rhs
	lhs.y *= rhs
}

func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
	return CGPointMake(rhs.x*lhs, rhs.y*lhs)
}

func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
	return CGPointMake(lhs.x/rhs, lhs.y/rhs)
}

func /=(inout lhs: CGPoint, rhs: CGFloat) {
	lhs.x /= rhs
	lhs.y /= rhs
}

func +(lhs: CGPoint, rhs: CGVector) -> CGPoint {
	return CGPointMake(lhs.x+rhs.dx, lhs.y+rhs.dy)
}

func -(lhs: CGPoint, rhs: CGVector) -> CGPoint {
	return CGPointMake(lhs.x-rhs.dx, lhs.y-rhs.dy)
}


// MARK: CGVector
func +(lhs: CGVector, rhs: CGVector) -> CGVector {
	return CGVectorMake(lhs.dx+rhs.dx, lhs.dy+rhs.dy)
}

func +=(inout lhs: CGVector, rhs: CGVector) {
	lhs.dx += rhs.dx
	lhs.dy += rhs.dy
}

func -(lhs: CGVector, rhs: CGVector) -> CGVector {
	return CGVectorMake(lhs.dx-rhs.dx, lhs.dy-rhs.dy)
}

func -=(inout lhs: CGVector, rhs: CGVector) {
	lhs.dx -= rhs.dx
	lhs.dy -= rhs.dy
}

func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
	return CGVectorMake(lhs.dx*rhs, lhs.dy*rhs)
}

func *=(inout lhs: CGVector, rhs: CGFloat) {
	lhs.dx *= rhs
	lhs.dy *= rhs
}

func *(lhs: CGFloat, rhs: CGVector) -> CGVector {
	return CGVectorMake(rhs.dx*lhs, rhs.dy*lhs)
}

func /(lhs: CGVector, rhs: CGFloat) -> CGVector {
	return CGVectorMake(lhs.dx/rhs, lhs.dy/rhs)
}

func /=(inout lhs: CGVector, rhs: CGFloat) {
	lhs.dx /= rhs
	lhs.dy /= rhs
}

// MARK: CGSize
func +(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSizeMake(lhs.width+rhs.width, lhs.height+rhs.height)
}

func +=(inout lhs: CGSize, rhs: CGSize) {
	lhs.width += rhs.width
	lhs.height += rhs.height
}

func -(lhs: CGSize, rhs: CGSize) -> CGSize {
	return CGSizeMake(lhs.width-rhs.width, lhs.height-rhs.height)
}

func -=(inout lhs: CGSize, rhs: CGSize) {
	lhs.width -= rhs.width
	lhs.height -= rhs.height
}

func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
	return CGSizeMake(rhs.width*lhs, rhs.height*lhs)
}

func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
	return CGSizeMake(lhs.width*rhs, lhs.height*rhs)
}

func *=(inout lhs: CGSize, rhs: CGFloat) {
	lhs.width *= rhs
	lhs.height *= rhs
}

func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
	return CGSizeMake(lhs.width/rhs, lhs.height/rhs)
}

func /=(inout lhs: CGSize, rhs: CGFloat) {
	lhs.width /= rhs
	lhs.height /= rhs
}

// MARK: CGRect
func *(lhs: CGRect, rhs: CGFloat) -> CGRect {
	return CGRectMake(lhs.origin.x*rhs, lhs.origin.y*rhs, lhs.size.width*rhs, lhs.size.height*rhs)
}

func *(lhs: CGFloat, rhs: CGRect) -> CGRect {
	return CGRectMake(rhs.origin.x*lhs, rhs.origin.y*lhs, rhs.size.width*lhs, rhs.size.height*lhs)
}

func *=(inout lhs: CGRect, rhs: CGFloat) {
	lhs.origin.x *= rhs
	lhs.origin.y *= rhs
	lhs.size.width *= rhs
	lhs.size.height *= rhs
}

func /(lhs: CGFloat, rhs: CGRect) -> CGRect {
	return CGRectMake(rhs.origin.x/lhs, rhs.origin.y/lhs, rhs.size.width/lhs, rhs.size.height/lhs)
}

func /(lhs: CGRect, rhs: CGFloat) -> CGRect {
	return CGRectMake(lhs.origin.x/rhs, lhs.origin.y/rhs, lhs.size.width/rhs, lhs.size.height/rhs)
}

func /=(inout lhs: CGRect, rhs: CGFloat) {
	lhs.origin.x /= rhs
	lhs.origin.y /= rhs
	lhs.size.width /= rhs
	lhs.size.height /= rhs
}

func +(lhs: CGRect, rhs: CGPoint) -> CGRect {
	return CGRectOffset(lhs, rhs.x, rhs.y)
}

func -(lhs: CGRect, rhs: CGPoint) -> CGRect {
	return CGRectOffset(lhs, -rhs.x, -rhs.y)
}

func +(lhs: CGRect, rhs: CGSize) -> CGRect {
	return CGRectMake(lhs.origin.x, lhs.origin.y, lhs.size.width+rhs.width, lhs.size.height+rhs.height)
}

func -(lhs: CGRect, rhs: CGSize) -> CGRect {
	return CGRectMake(lhs.origin.x, lhs.origin.y, lhs.size.width-rhs.width, lhs.size.height-rhs.height)
}

// MARK: - helpers

/// Determines whether the second vector is above > 0 or below < 0 the first one
func *(lhs: CGPoint, rhs: CGPoint ) -> CGFloat {
	return lhs.x*rhs.y - lhs.y*rhs.x
}

/// smallest angle between 2 angles
func arcFi( fi1: CGFloat, fi2: CGFloat ) -> CGFloat {
	let p = CGPointMake(cos(fi1)-cos(fi2), sin(fi1)-sin(fi2))
	
	let dSqr = p.x*p.x + p.y*p.y
	
	let fi = acos(1-dSqr/2)
	
	return fi
}

/// whether fi2 is larger than fi1 in reference to the ref angle
func compareAngles( ref: CGFloat, fi1: CGFloat, fi2: CGFloat ) -> CGFloat {
	return -arcFi(ref, fi2: fi1)+arcFi(ref, fi2: fi2)
}

/// intersection

func lineIntersection( segmentStart p1:CGPoint, segmentEnd p2:CGPoint,
	lineStart p3:CGPoint, lineEnd p4:CGPoint,
	insideSegment: Bool = true, lineIsSegment: Bool = false, hardUpperLimit: Bool = false ) -> CGPoint? {
		
		let parallel = CGFloat(p1.x-p2.x)*CGFloat(p3.y-p4.y) - CGFloat(p1.y-p2.y)*CGFloat(p3.x-p4.x) == 0
		
		if parallel == false {
			let intersection = CGPointMake(
				((CGFloat(p1.x*p2.y) - CGFloat(p1.y*p2.x))*CGFloat(p3.x-p4.x) - CGFloat(p1.x-p2.x)*(CGFloat(p3.x*p4.y) - CGFloat(p3.y*p4.x))) / (CGFloat(p1.x-p2.x)*CGFloat(p3.y-p4.y) - CGFloat(p1.y - p2.y)*CGFloat(p3.x-p4.x)),
				((CGFloat(p1.x*p2.y) - CGFloat(p1.y*p2.x))*CGFloat(p3.y-p4.y) - CGFloat(p1.y-p2.y)*(CGFloat(p3.x*p4.y) - CGFloat(p3.y*p4.x))) / (CGFloat(p1.x-p2.x)*CGFloat(p3.y-p4.y) - CGFloat(p1.y - p2.y)*CGFloat(p3.x-p4.x))
			)
			
			
			if insideSegment {
				let u = p2.x == p1.x ? 0 : (intersection.x - p1.x) / (p2.x - p1.x)
				let v = p2.y == p1.y ? 0 : (intersection.y - p1.y) / (p2.y - p1.y)
				
				if u<0 || v<0 || v>1 || u>1 || hardUpperLimit && (v>=1 || u>=1) {
					return nil
				}
				
				if lineIsSegment {
					let w = p4.x == p3.x ? 0 : (intersection.y - p3.x) / (p4.x - p3.x)
					let x = p4.y == p3.y ? 0 : (intersection.y - p3.y) / (p4.y - p3.y)
					
					if w<0 || x<0 || w>1 || x>1 || hardUpperLimit && (w>=1 || x>=1) {
						return nil
					}
				}
			}
			
			return intersection
		}
		
		return nil
}


func segmentsIntersection(segment1: (CGPoint, CGPoint), _ segment2: (CGPoint, CGPoint)) -> CGPoint? {
	return lineIntersection(segmentStart: segment1.0, segmentEnd: segment1.1, lineStart: segment2.0, lineEnd: segment2.1,
		insideSegment: true, lineIsSegment: true, hardUpperLimit: true)
}

// MARK: - extensions

extension CGFloat {
	static let Pi = CGFloat(M_PI)
	
	static func random(d:CGFloat = 1) -> CGFloat {
		
		return CGFloat(arc4random())/CGFloat(UInt32.max) * d
		
	}
}

extension CGRect {
	var topLeft: CGPoint {
		return CGPointMake(self.minX, self.minY)
	}
	
	var topRight: CGPoint {
		return CGPointMake(self.maxX, self.minY)
	}
	
	var bottomLeft: CGPoint {
		return CGPointMake(self.minX, self.maxY)
	}
	
	var bottomRight: CGPoint {
		return CGPointMake(self.maxX, self.maxY)
	}
	
	var topMiddle: CGPoint {
		return CGPointMake(self.midX, self.minY)
	}
	
	var bottomMiddle: CGPoint {
		return CGPointMake(self.midX, self.maxY)
	}
	
	var middleLeft: CGPoint {
		return CGPointMake(self.minY, self.midY)
	}
	
	var middleRight: CGPoint {
		return CGPointMake(self.maxY, self.midY)
	}
	
	var center: CGPoint {
		return CGPointMake(self.midX, self.midY)
	}
}

extension CGPoint {
	/// distance to another point
	func distanceTo(point: CGPoint) -> CGFloat {
		return sqrt(pow(self.x-point.x, 2) + pow(self.y-point.y, 2))
	}
	
	func integral() -> CGPoint {
		return CGPointMake(round(self.x), round(self.y))
	}
	
	mutating func integrate() {
		self.x = round(self.x)
		self.y = round(self.y)
	}
}

extension CGVector {
	
	init(point: CGPoint) {
		self.dx = point.x
		self.dy = point.y
	}
	
	var length: CGFloat {
		return sqrt(self.dx*self.dx+self.dy*self.dy)
	}
}

extension CGPoint {
	
	init(vector: CGVector) {
		self.x = vector.dx
		self.y = vector.dy
	}
	
}
