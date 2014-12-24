//
//  RangeSampler.swift
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


import Foundation

extension Range {
	
	/** 
	Generates a sample for each index in the range
	
	:param: sample returns a new sample at provided position
	:param: newSampleRequired determines whether another split should be performed
	
	:returns: samples for each index in the range, with additional samples in between according to the rules provided by the newSampleRequired
	*/
	
	func generateSamples<T>(sample:(Double) -> T, newSampleRequired:([T], Int) -> Bool) -> [T] {
		
		var values = [T]()
		var i = 0

		self.map { (j) -> () in
			
			var sampleAdd = true
			var sampleAdded = true
			
			var fraction = 0.0
			
			var levelPrev = -1
			var level = -1
			var levels = 0
			
			do {
				
				if sampleAdd {
					
					if !sampleAdded && level < 0b111 { // starting a new split
						levels = (levels<<6) | ((level&0b111)<<3) | (levelPrev&0b111)
					}
					
					level = (max(level, levelPrev)+1)
					if level > 0 {
						fraction -= pow(1/2.0, Double(level))
					}
					
					// insert new data point
					let t = Double(j as Int) + fraction
					values.insert(sample(t), atIndex: i)
					
				} else {
					
					fraction += pow(1/2.0, Double(level))
					
					levelPrev = level
					level--
					
					// ending a subsplit
					if level == levels&0b111 {
						level = (levels>>3)&0b111
						levels >>= 6
					}
					
					i++
				}
				
				// determine what to do next
				sampleAdded = sampleAdd
				
				sampleAdd = i != 0
				if values.count > 1 {
					sampleAdd = newSampleRequired(values, i)
				}
				
			} while sampleAdd || fraction != 0
			
			i++
		}
		
		return values
	}
}