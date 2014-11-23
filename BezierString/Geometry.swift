//
//  Geometry.swift
//
//  Created by Luka on 27. 08. 14.
//  Copyright (c) 2014 lvnyk. All rights reserved.
//

import UIKit

// MARK: - calculations
// MARK: CGPoint
func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPointMake(lhs.x+rhs.x, lhs.y+rhs.y)
}

func +=(inout lhs: CGPoint, rhs: CGPoint) {
	lhs.x += rhs.x
	lhs.y += rhs.x
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
	return CGPointMake(lhs.x-rhs.x, lhs.y-rhs.y)
}

func -=(inout lhs: CGPoint, rhs: CGPoint) {
	lhs.x -= rhs.x
	lhs.y -= rhs.x
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
	return -arcFi(ref, fi1)+arcFi(ref, fi2)
}

// reasonable time issues blahblah
//func lineIntersection( segmentStart p1:CGPoint, segmentEnd p2:CGPoint, lineStart p3:CGPoint, lineEnd p4:CGPoint, insideSegment: Bool = true ) -> CGPoint? {
//	
//	let parallel = CGFloat(p1.x-p2.x)*CGFloat(p3.y-p4.y) - CGFloat(p1.y-p2.y)*CGFloat(p3.x-p4.x) == 0
//
//	if parallel == false {
//		let intersection = CGPointMake(
//			((CGFloat(p1.x*p2.y) - CGFloat(p1.y*p2.x))*CGFloat(p3.x-p4.x) - CGFloat(p1.x-p2.x)*(CGFloat(p3.x*p4.y) - CGFloat(p3.y*p4.x))) / (CGFloat(p1.x-p2.x)*CGFloat(p3.y-p4.y) - CGFloat(p1.y - p2.y)*CGFloat(p3.x-p4.x)),
//			((CGFloat(p1.x*p2.y) - CGFloat(p1.y*p2.x))*CGFloat(p3.y-p4.y) - CGFloat(p1.y-p2.y)*(CGFloat(p3.x*p4.y) - CGFloat(p3.y*p4.x))) / (CGFloat(p1.x-p2.x)*CGFloat(p3.y-p4.y) - CGFloat(p1.y - p2.y)*CGFloat(p3.x-p4.x))
//		)
//
//		let u = p2.x == p1.x ? 0 : (intersection.x - p1.x) / (p2.x - p1.x)
//		let v = p2.y == p1.y ? 0 : (intersection.y - p1.y) / (p2.y - p1.y)
//		
//		if insideSegment && ( u < 0 || u > 1 || v < 0 || v > 1 ) {
//			return nil
//		}
//		
//		return intersection
//	}
//	
//	return nil
//}

// MARK: - extensions

extension CGFloat {
	static let Pi = CGFloat(M_PI)
}

extension CGRect {
	var topLeft: CGPoint {
		get { return CGPointMake(self.minX, self.minY); }
	}
	
	var topRight: CGPoint {
		get { return CGPointMake(self.maxX, self.minY); }
	}
	
	var bottomLeft: CGPoint {
		get { return CGPointMake(self.minX, self.maxY); }
	}
	
	var bottomRight: CGPoint {
		get { return CGPointMake(self.maxX, self.maxY); }
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