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
public func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
}

public func +=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs.x += rhs.x
    lhs.y += rhs.y
}

public func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x-rhs.x, y: lhs.y-rhs.y)
}

public func -=(lhs: inout CGPoint, rhs: CGPoint) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
}

public func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x*rhs, y: lhs.y*rhs)
}

public func *=(lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x *= rhs
    lhs.y *= rhs
}

public func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: rhs.x*lhs, y: rhs.y*lhs)
}

public func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
    return CGPoint(x: lhs.x/rhs, y: lhs.y/rhs)
}

public func /=(lhs: inout CGPoint, rhs: CGFloat) {
    lhs.x /= rhs
    lhs.y /= rhs
}

public func +(lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x+rhs.dx, y: lhs.y+rhs.dy)
}

public func -(lhs: CGPoint, rhs: CGVector) -> CGPoint {
    return CGPoint(x: lhs.x-rhs.dx, y: lhs.y-rhs.dy)
}

public prefix func -(lhs: CGPoint) -> CGPoint {
    return CGPoint(x: -lhs.x, y: -lhs.y)
}

// MARK: CGVector
public func +(lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx+rhs.dx, dy: lhs.dy+rhs.dy)
}

public func +=(lhs: inout CGVector, rhs: CGVector) {
    lhs.dx += rhs.dx
    lhs.dy += rhs.dy
}

public func -(lhs: CGVector, rhs: CGVector) -> CGVector {
    return CGVector(dx: lhs.dx-rhs.dx, dy: lhs.dy-rhs.dy)
}

public func -=(lhs: inout CGVector, rhs: CGVector) {
    lhs.dx -= rhs.dx
    lhs.dy -= rhs.dy
}

public func *(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx*rhs, dy: lhs.dy*rhs)
}

public func *=(lhs: inout CGVector, rhs: CGFloat) {
    lhs.dx *= rhs
    lhs.dy *= rhs
}

public func *(lhs: CGFloat, rhs: CGVector) -> CGVector {
    return CGVector(dx: rhs.dx*lhs, dy: rhs.dy*lhs)
}

public func /(lhs: CGVector, rhs: CGFloat) -> CGVector {
    return CGVector(dx: lhs.dx/rhs, dy: lhs.dy/rhs)
}

public func /=(lhs: inout CGVector, rhs: CGFloat) {
    lhs.dx /= rhs
    lhs.dy /= rhs
}

// MARK: CGSize
public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width+rhs.width, height: lhs.height+rhs.height)
}

public func +=(lhs: inout CGSize, rhs: CGSize) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}

public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width-rhs.width, height: lhs.height-rhs.height)
}

public func -=(lhs: inout CGSize, rhs: CGSize) {
    lhs.width -= rhs.width
    lhs.height -= rhs.height
}

public func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
    return CGSize(width: rhs.width*lhs, height: rhs.height*lhs)
}

public func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width*rhs, height: lhs.height*rhs)
}

public func *=(lhs: inout CGSize, rhs: CGFloat) {
    lhs.width *= rhs
    lhs.height *= rhs
}

public func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
}

public func /=(lhs: inout CGSize, rhs: CGFloat) {
    lhs.width /= rhs
    lhs.height /= rhs
}

// MARK: CGRect
public func *(lhs: CGRect, rhs: CGFloat) -> CGRect {
    return CGRect(origin: lhs.origin*rhs, size: lhs.size*rhs)
}

public func *(lhs: CGFloat, rhs: CGRect) -> CGRect {
    return CGRect(origin: lhs*rhs.origin, size: lhs*rhs.size)
}

public func *=(lhs: inout CGRect, rhs: CGFloat) {
    lhs.origin *= rhs
    lhs.size *= rhs
}

public func /(lhs: CGRect, rhs: CGFloat) -> CGRect {
    return CGRect(origin: lhs.origin/rhs, size: lhs.size/rhs)
}

public func /=(lhs: inout CGRect, rhs: CGFloat) {
    lhs.origin /= rhs
    lhs.size /= rhs
}

public func +(lhs: CGRect, rhs: CGPoint) -> CGRect {
    return lhs.offsetBy(dx: rhs.x, dy: rhs.y)
}

public func -(lhs: CGRect, rhs: CGPoint) -> CGRect {
    return lhs.offsetBy(dx: -rhs.x, dy: -rhs.y)
}

public func +(lhs: CGRect, rhs: CGSize) -> CGRect {
    return CGRect(origin: lhs.origin, size: lhs.size+rhs)
}

public func -(lhs: CGRect, rhs: CGSize) -> CGRect {
    return CGRect(origin: lhs.origin, size: lhs.size-rhs)
}

// MARK: - helpers

/// Determines whether the second vector is above > 0 or below < 0 the first one
public func *(lhs: CGPoint, rhs: CGPoint ) -> CGFloat {
    return lhs.x*rhs.y - lhs.y*rhs.x
}

/// smallest angle between 2 angles
public func arc(fi1: CGFloat, fi2: CGFloat) -> CGFloat {
    let p = CGPoint(x: cos(fi1)-cos(fi2), y: sin(fi1)-sin(fi2))
    
    let dSqr = p.x*p.x + p.y*p.y
    
    guard dSqr < 4 else { return CGFloat.pi }
    let fi = acos(1-dSqr/2)
    
    return fi
}

/// whether fi2 is larger than fi1 in reference to the ref angle
public func compareAngles( _ ref: CGFloat, fi1: CGFloat, fi2: CGFloat ) -> CGFloat {
    return -arc(fi1: ref, fi2: fi1)+arc(fi1: ref, fi2: fi2)
}

// diff between 2 values in cw direction from the first
func cwDiff(fi1: CGFloat, fi2: CGFloat) -> CGFloat {
    
    let diff = arc(fi1: fi1, fi2: fi2)
    
    if arc(fi1: fi1+diff, fi2: fi2) == 0 {
        return diff
    }
    
    return -diff
}

func cwDiff(fi1: Int, fi2: Int, size: Int) -> Int {
    
    let fi1 = CGFloat(fi1)*CGFloat.pi*2/CGFloat(size)
    let fi2 = CGFloat(fi2)*CGFloat.pi*2/CGFloat(size)
    
    return Int(round(cwDiff(fi1: fi1, fi2: fi2) * CGFloat(size)/(CGFloat.pi*2)))
}

/// intersection

public func lineIntersection(segmentStart p1:CGPoint, segmentEnd p2:CGPoint,
                             lineStart p3:CGPoint, lineEnd p4:CGPoint,
                             insideSegment: Bool = true, lineIsSegment: Bool = false, hardUpperLimit: Bool = false ) -> CGPoint? {
    
    let parallel = (p1.x-p2.x)*(p3.y-p4.y) - (p1.y-p2.y)*(p3.x-p4.x) == CGFloat(0)
    
    if parallel == false {
        
        let x: CGFloat = ((p1.x*p2.y - p1.y*p2.x)*(p3.x-p4.x) - (p1.x-p2.x)*(p3.x*p4.y - p3.y*p4.x)) / ((p1.x-p2.x)*(p3.y-p4.y) - (p1.y - p2.y)*(p3.x-p4.x))
        let y: CGFloat = ((p1.x*p2.y - p1.y*p2.x)*(p3.y-p4.y) - (p1.y-p2.y)*(p3.x*p4.y - p3.y*p4.x)) / ((p1.x-p2.x)*(p3.y-p4.y) - (p1.y - p2.y)*(p3.x-p4.x))
        let intersection = CGPoint(
            x: x,
            y: y
        )
        
        if insideSegment {
            let u = p2.x == p1.x ? CGFloat(0) : (intersection.x - p1.x) / (p2.x - p1.x)
            let v = p2.y == p1.y ? CGFloat(0) : (intersection.y - p1.y) / (p2.y - p1.y)
            
            if u<CGFloat(0) || v<CGFloat(0) || v>CGFloat(1) || u>CGFloat(1) || hardUpperLimit && (v>=CGFloat(1) || u>=CGFloat(1)) {
                return nil
            }
            
            if lineIsSegment {
                let w = p4.x == p3.x ? CGFloat(0) : (intersection.y - p3.x) / (p4.x - p3.x)
                let x = p4.y == p3.y ? CGFloat(0) : (intersection.y - p3.y) / (p4.y - p3.y)
                
                if w<CGFloat(0) || x<CGFloat(0) || w>CGFloat(1) || x>CGFloat(1) || hardUpperLimit && (w>=CGFloat(1) || x>=CGFloat(1)) {
                    return nil
                }
            }
        }
        
        return intersection
    }
    
    return nil
}


public func segmentsIntersection(_ segment1: (CGPoint, CGPoint), _ segment2: (CGPoint, CGPoint)) -> CGPoint? {
    return lineIntersection(segmentStart: segment1.0, segmentEnd: segment1.1, lineStart: segment2.0, lineEnd: segment2.1,
                            insideSegment: true, lineIsSegment: true, hardUpperLimit: true)
}

/// center of circle through points

public func circleCenter(_ p0: CGPoint, p1: CGPoint, p2: CGPoint) -> CGPoint? {
    
    let p01 = (p0+p1)/2 // midpoint
    let p12 = (p1+p2)/2
    
    let t01 = p1-p0 // parallel -> tangent
    let t12 = p2-p1
    
    return
        lineIntersection(
            segmentStart: p01,
            segmentEnd: p01 + CGPoint(x: -t01.y, y: t01.x),
            lineStart: p12,
            lineEnd: p12 + CGPoint(x: -t12.y, y: t12.x),
            insideSegment: false)
    
    
}

// MARK: - extensions

extension CGFloat {
    static let phi = CGFloat(1.618033988749894848204586834)
}

extension CGRect {
    public var topLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.minY)
    }
    
    public var topRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.minY)
    }
    
    public var bottomLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.maxY)
    }
    
    public var bottomRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.maxY)
    }
    
    public var topMiddle: CGPoint {
        return CGPoint(x: self.midX, y: self.minY)
    }
    
    public var bottomMiddle: CGPoint {
        return CGPoint(x: self.midX, y: self.maxY)
    }
    
    public var middleLeft: CGPoint {
        return CGPoint(x: self.minX, y: self.midY)
    }
    
    public var middleRight: CGPoint {
        return CGPoint(x: self.maxX, y: self.midY)
    }
    
    public var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }
    
    public func transformed(_ t: CGAffineTransform) -> CGRect {
        return self.applying(t)
    }
    
}


extension CGPoint {
    /// distance to another point
    public func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(self.x-point.x, 2) + pow(self.y-point.y, 2))
    }
    
    public func integral() -> CGPoint {
        return CGPoint(x: round(self.x), y: round(self.y))
    }
    
    public mutating func integrate() {
        self.x = round(self.x)
        self.y = round(self.y)
    }
    
    public func transformed(_ t: CGAffineTransform) -> CGPoint {
        return self.applying(t)
    }
    
    public func normalized() -> CGPoint {
        if self == .zero {
            return CGPoint(x: 1, y: 0)
        }
        return self/self.distance(to: .zero)
    }
}


extension CGPoint {
    /// grow a rect from center
    public func expand(to size: CGSize) -> CGRect {
        return CGRect(origin: self, size: .zero).insetBy(dx: -size.width/2, dy: -size.height/2)
    }
    
}


extension CGVector {
    
    public init(point: CGPoint) {
        self = CGVector(dx: point.x, dy: point.y)
    }
    
    public init(size: CGSize) {
        self = CGVector(dx: size.width, dy: size.height)
    }
    
    public var length: CGFloat {
        return sqrt(self.dx*self.dx+self.dy*self.dy)
    }
}

extension CGPoint {
    
    public init(vector: CGVector) {
        self = CGPoint(x: vector.dx, y: vector.dy)
    }
    
}

extension CGSize {
    public func integral() -> CGSize {
        var s = self
        s.integrate()
        return s
    }
    
    public mutating func integrate() {
        self.width = round(self.width)
        self.height = round(self.height)
    }
}
