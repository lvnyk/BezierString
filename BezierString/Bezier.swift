//
//  BezierPath.swift
//
//  Created by Luka on 26/12/15.
//  Copyright (c) 2015 lvnyk.
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

// MARK: Helpers

extension CGPath {
	
	typealias Applier = @convention(block) (UnsafePointer<CGPathElement>) -> ()
	func forEach(_ applier: Applier) {
		
		let callback: CGPathApplierFunction = { (info, element) in
			let applier = unsafeBitCast(info, to: Applier.self)
			applier(element)
		}
		
		self.apply(info: unsafeBitCast(applier, to: UnsafeMutableRawPointer.self), function: callback)
	}
}

class Box<T> {
	var value: T
	init(value: T) {
		self.value = value
	}
}

// MARK: - Bezier Path

/// Contains a list of Bezier Curves

struct Bezier {
	
	/// Bezier Curve of the n-th order
	struct Curve {
		
		typealias Value = (value: CGFloat, at: CGFloat)
		
		let points: [CGPoint]
		fileprivate let diffs: [CGPoint]
		fileprivate let cache = Box(value: [Value(0, 0)])
		
		init(point: CGPoint...) {
			points = point
			diffs  = zip(point.dropFirst(), point).map(-)
		}
	}
	
	let path: CGPath // CGPath used instead of UIBezierPath for its immutability
	fileprivate let curves: [Curve]
	
	/// - parameter path: UIBezierPath - preferably continuous
	init(path: CGPath) {
		
		self.path = path
		
		var curves = [Curve]()
		var last: CGPoint?
		
		path.forEach({
			let p = $0.pointee
			switch p.type {
			case .moveToPoint:
				last = p.points[0]
			case .addLineToPoint:
				if let first = last {
					last = p.points[0]
					curves.append(Curve(point: first, last!))
				}
			case .addQuadCurveToPoint:
				if let first = last {
					last = p.points[1]
					curves.append(Curve(point: first, p.points[0], last!))
				}
			case .addCurveToPoint:
				if let first = last {
					last = p.points[2]
					curves.append(Curve(point: first, p.points[0], p.points[1], last!))
				}
			case .closeSubpath:
				last = nil
				break;
			}
		})
		
		self.curves = curves
	}
	
}

// MARK: - BezierCurve

extension Bezier.Curve {
	
	struct Binomial {
		private static var c = [[1]]
		
		/// - returns: Binomial Coefficients for the order n
		static func coefficients(for n: Int) -> [Int] {
			if n < Binomial.c.count {
				return Binomial.c[n]
			}
			
			let prev = coefficients(for: (n - 1))
			let new = zip([0]+prev, prev+[0]).map(+)
			Binomial.c.append(new)
			return new
		}
		
		/// Sums up the list of items
		static func sum(_ list: [CGPoint], t: CGFloat) -> CGPoint {
			let count = CGFloat(list.count)
			return zip(Binomial.coefficients(for: list.count - 1), list).enumerated().reduce(CGPoint.zero) { sum, d in
				let i = CGFloat(d.offset)
				let b = CGFloat(d.element.0)
				
				return sum + pow(t, i)*pow(1-t, count-1-i) * b * d.element.1
			}
		}
	}
	
	/**
	Finds the parameter t for given length
	- parameter length: length along the path
	- parameter left: left value for initial bisection (only used if no values have been previously cached)
	- returns: parameter t
	*/
	func t(at length: CGFloat, left: Value=(0,0)) -> Value {
		
		let length = max(0, min(length, self.length()))
		
		if let t = cache.value.lazy.filter({$0.value == length}).first {
			return t
		}
		let left  = cache.value.lazy.filter({$0.value < length}).last  ?? left
		let right = cache.value.lazy.filter({$0.value > length}).first ?? (self.length(), 1)
		
		return bisect(length, left: left, right: right)
	}
	
	/**
	Recursive bisection step while searching for the parameter t
	- parameter find: length for which we're searching t for
	- parameter left: left boundary
	- parameter right: right boundary
	- parameter depth: bisection step number
	- returns: final value
	*/
	func bisect(_ find: CGFloat, left: Value, right: Value, depth: Int = 0) -> Value {
		
		let split = (find-left.value)/(right.value-left.value)	// 0...1
		let t     = (left.at*(1-split) + right.at*(split))		// search for the solution closer to the boundary that it is nearer to
		
		let guess = Value(self.length(at: t), t)
		
		if abs(find-guess.value) < 0.15 || depth > 10 {
			return guess
		}
		
		if guess.value < find {
			return bisect(find, left: guess, right: right, depth: (depth + 1))
		} else {
			return bisect(find, left: left,  right: guess, depth: (depth + 1))
		}
	}
	
	/// - returns: Derivative of the curve at t
	func d(at t:CGFloat) -> CGPoint {
		return Binomial.sum(diffs, t: t) * CGFloat(diffs.count)
	}
	
	/// - returns: Location on the curve at t
	func position(at t: CGFloat) -> CGPoint {
		return Binomial.sum(points, t: t)
	}
	
	/// Calculated using the [Gauss-Legendre quadrature](http://pomax.github.io/bezierinfo/legendre-gauss.html)
	/// - returns: Length of the curve at t
	func length(at t: CGFloat=1) -> CGFloat {
		
		let t = max(0, min(t, 1))
		if let length = cache.value.lazy.filter({$0.at==t}).first {
			return length.value
		}
		
		// Gauss-Legendre quadrature
		let length = Bezier.Curve.glvalues[(diffs.count - 1)].reduce(CGFloat(0.0)) { sum, table in
			let tt = t/2 * (table.abscissa + 1)
			return sum + t/2 * table.weight * self.d(at: tt).distanceTo(.zero)
		}
		
		cache.value.insert((length, t), at: cache.value.index { $0.at>t } ?? cache.value.endIndex) // keep it sorted
		
		return length
	}
	
	/// [Weight and abscissa](http://pomax.github.io/bezierinfo/legendre-gauss.html) values
	private static let glvalues:[[(weight: CGFloat, abscissa: CGFloat)]] = [
		[	// line - 2
			(1.0000000000000000, -0.5773502691896257),
			(1.0000000000000000,  0.5773502691896257)
		],
		[	// quadratic - 16
			(0.1894506104550685, -0.0950125098376374),
			(0.1894506104550685,  0.0950125098376374),
			(0.1826034150449236, -0.2816035507792589),
			(0.1826034150449236,  0.2816035507792589),
			(0.1691565193950025, -0.4580167776572274),
			(0.1691565193950025,  0.4580167776572274),
			(0.1495959888165767, -0.6178762444026438),
			(0.1495959888165767,  0.6178762444026438),
			(0.1246289712555339, -0.7554044083550030),
			(0.1246289712555339,  0.7554044083550030),
			(0.0951585116824928, -0.8656312023878318),
			(0.0951585116824928,  0.8656312023878318),
			(0.0622535239386479, -0.9445750230732326),
			(0.0622535239386479,  0.9445750230732326),
			(0.0271524594117541, -0.9894009349916499),
			(0.0271524594117541,  0.9894009349916499)
		],
		[	// cubic - 24
			(0.1279381953467522, -0.0640568928626056),
			(0.1279381953467522,  0.0640568928626056),
			(0.1258374563468283, -0.1911188674736163),
			(0.1258374563468283,  0.1911188674736163),
			(0.1216704729278034, -0.3150426796961634),
			(0.1216704729278034,  0.3150426796961634),
			(0.1155056680537256, -0.4337935076260451),
			(0.1155056680537256,  0.4337935076260451),
			(0.1074442701159656, -0.5454214713888396),
			(0.1074442701159656,  0.5454214713888396),
			(0.0976186521041139, -0.6480936519369755),
			(0.0976186521041139,  0.6480936519369755),
			(0.0861901615319533, -0.7401241915785544),
			(0.0861901615319533,  0.7401241915785544),
			(0.0733464814110803, -0.8200019859739029),
			(0.0733464814110803,  0.8200019859739029),
			(0.0592985849154368, -0.8864155270044011),
			(0.0592985849154368,  0.8864155270044011),
			(0.0442774388174198, -0.9382745520027328),
			(0.0442774388174198,  0.9382745520027328),
			(0.0285313886289337, -0.9747285559713095),
			(0.0285313886289337,  0.9747285559713095),
			(0.0123412297999872, -0.9951872199970213),
			(0.0123412297999872,  0.9951872199970213)
		]
	]
}

// MARK: - API

extension Bezier {
	
	/// - returns: Total length of the path
	func length() -> CGFloat {
		return self.curves.reduce(CGFloat(0)) { sum, c in
			return sum + c.length()
		}
	}
	
	/// - returns: Path properties (position and normal) at given length.
	/// nil if out of bounds
	func properties(at length: CGFloat) -> (position: CGPoint, normal: CGFloat)? {
		var length = length
		for curve in curves {
			let l = curve.length()
			if length <= l {
				let t   = curve.t(at: length).at
				let pos = curve.position(at: t)
				let rot = curve.d(at: t)
				
				return (pos, atan2(rot.y, rot.x))
			}
			length -= l
		}
		
		return nil
	}
	
}
