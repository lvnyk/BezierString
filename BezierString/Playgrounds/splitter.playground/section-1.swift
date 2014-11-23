// Playground - noun: a place where people can play

import UIKit

var values = [Double]()
var i = 0

for j in 0...3 {
	
	var sampleAdd = true
	var sampleAdded = true
	
	var fraction = 0.0
	
	var levelPrev = -1
	var level = -1
	var levels = 0
	
	do {
		
		if sampleAdd {
			
			if !sampleAdded && level < 0b111 { // we're starting a new split
				levels = (levels<<6) | ((level&0b111)<<3) | (levelPrev&0b111)
			}
			
			level = (max(level, levelPrev)+1)
			if ( level > 0 ) {
				fraction -= pow(1/2.0, Double(level))
			}
			
			// insert new data point
			let t = Double(j)+fraction
			values.insert(t, atIndex: i)
			
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

		// check
		sampleAdded = sampleAdd
		sampleAdd = i != 0
		if values.count > 1 {
			sampleAdd = abs(values[i]-values[i-1]) > 0.2
		}
		
		// print
		fraction
		
	} while sampleAdd || fraction != 0
	
	i++
	
}

// print
for v in values { v }
values
