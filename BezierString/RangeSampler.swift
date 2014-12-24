//
//  RangeSampler.swift
//
//  Created by Luka on 22. 11. 14.
//  Copyright (c) 2014 lvnyk. All rights reserved.
//

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