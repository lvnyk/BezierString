## Updated for Swift 3


BezierString
============

Rendering `NSAttributedStrings` along arbitrary continuous `UIBezierPaths`

## Example

![joe](https://raw.githubusercontent.com/lvnyk/BezierString/master/where.png)

#### 1. Create a bezier path and an attributed string

	let bezierPath = UIBezierPath()
	bezierPath.move(to: CGPoint(x: 50, y: 50+100))
	bezierPath.addCurve(to: CGPoint(x: 50+200, y: 50),
	                    controlPoint1: CGPoint(x: 50+10, y: 50+75),
	                    controlPoint2: CGPoint(x: 50+100, y: 50))
	bezierPath.addCurve(to: CGPoint(x: 50+400, y: 50+150),
	                    controlPoint1: CGPoint(x: 50+300, y: 50),
	                    controlPoint2: CGPoint(x: 50+400-10, y: 50+75))

	let attributedString = NSAttributedString(
		string: "Where did you come from, where did you go?",
		attributes: [
			NSFontAttributeName: UIFont.systemFont(ofSize: 20, weight: UIFontWeightUltraLight),
			NSForegroundColorAttributeName: UIColor.red
		])
	

#### 2. Use the BezierPath
	
	let bezier = Bezier(path: bezierPath.cgPath)
	
	// generate an image
	let image = bezier.image(withAttributed: attributedString)

	// or render onto a preexisting context
	bezier.draw(attributed: attributedString, to: UIGraphicsGetCurrentContext()!)

#### UIBezierLabel
Alternatively, in place of `UILabel`, use a `UIBezierLabel` instance, assign a `bezierString` or `bezierPath` and use as a normal `UILabel`

	// create a label, either in code or Interface Builder
	let label = UIBezierLabel(frame: .zero)
		
	// set the properties
	label.bezierPath = bezierPath.cgPath
	label.textAlignment = .center
	label.text = "Where did you come from, where did you go?"
	label.sizeToFit()

## Requirements
	
- Xcode 8.0+
- iOS 7.0+