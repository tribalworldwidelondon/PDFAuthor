/*
 MIT License
 
 Copyright (c) 2017 Tribal Worldwide London
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import CoreGraphics
import Cassowary

// MARK: - Constraints
extension PDFRegion {

	// MARK: Constraint Anchors

	/// An anchor specifying the right edge of the region.
	public var right:       Expression {
		return (left + width).setAlias("right", owner: self)
	}

	/// An anchor specifying the bottom edge of the region.
	public var bottom:      Expression {
		return (top + height).setAlias("bottom", owner: self)
	}

	/// An anchor specifying the horizontal center of the region.
	public var centerX:     Expression {
		return ((left + right) / 2.0).setAlias("centerX", owner: self)
	}

	/// An anchor specifying the vertical center of the region.
	public var centerY:     Expression {
		return ((top + bottom) / 2.0).setAlias("centerY", owner: self)
	}

	/// An anchor specifying the leading edge of the region.
	public var leading:     Expression {
		// TODO- Figure out how to support right to left languages
		return Expression(term: Term(variable: left)).setAlias("leading", owner: self)
	}

	/// An anchor specifying the trailing edge of the region.
	public var trailing:    Expression {
		// TODO- Figure out how to support right to left languages
		return (left + width).setAlias("trailing", owner: self)
	}

	/// An anchor specifying the left inset of the region.
	public var leftInset:   Expression {
		return (left + edgeInsetLeft).setAlias("leftInset", owner: self)
	}

	/// An anchor specifying the right inset of the region.
	public var rightInset:  Expression {
		return (right - edgeInsetRight).setAlias("rightInset", owner: self)
	}

	/// An anchor specifying the top inset of the region.
	public var topInset:    Expression {
		return (top + edgeInsetTop).setAlias("topInset", owner: self)
	}

	/// An anchor specifying the bottom inset of the region.
	public var bottomInset: Expression {
		return (bottom - edgeInsetBottom).setAlias("bottomInset", owner: self)
	}

	// MARK: Add constraints

	/**
	 Add a constraint to the region.
	 - parameters:
		 - constraint: The constraint to add
	 */
	public func addConstraint(_ constraint: Constraint) {
		constraints.append(constraint)
	}

	/**
	 Add constraints to the region.
	 - parameters:
		 - constraints: The constraints to add
	 */
	public func addConstraints(_ constraints: Constraint...) {
		self.constraints.append(contentsOf: constraints)
	}

	/**
	 Add constraints to the region.
	 - parameters:
		 - constraints: An array of constraints to add
	 */
	public func addConstraints(_ constraints: [Constraint]) {
		self.constraints.append(contentsOf: constraints)
	}

	// MARK: Constraint calculation
	private func recursivelyGetConstraints() -> [Constraint] {
		return constraints + children.flatMap { $0.recursivelyGetConstraints() }
	}

	private func recursivelyGetSuggestedValues() -> [(Variable, Double, Double)] {
		return suggestedVariableValues + children.flatMap { $0.recursivelyGetSuggestedValues() }
	}

	internal func calculateConstraints() {
		let solver = Solver()
		solveConstraints(solver)
	}

	internal func solveConstraints(_ solver: Solver, silenceError: Bool = false) {
		var allConstraints: [Constraint] = []

		allConstraints.append(contentsOf: recursivelyGetConstraints())

		for constraint in allConstraints {
			do {
				try solver.addConstraint(constraint)
			} catch let error as CassowaryError {
				if case CassowaryError.unsatisfiableConstraint(let constraint, _) = error {
					var msg = error.detailedDescription()
					msg += "\n\tThe following constraint has not been added:\n"
					msg += "\t\t\(constraint.description)"

					print(msg)
				} else {
					print("Unknown constraint solver error!")
					print(error)
				}
			} catch {
				print("Unknown constraint solver error!")
			}
		}

		solver.updateVariables()

		// Get suggested values after constraint variables have already been updated to allow, for instance,
		// String region to suggest a height based on its constrained width.

		let suggestedValues = recursivelyGetSuggestedValues()
		for (variable, strength, suggestedValue) in suggestedValues {
			do {
				try solver.addEditVariable(variable: variable, strength: strength)
				try solver.suggestValue(variable: variable, value: suggestedValue)
			} catch {
				print("Error adding edit variable: \(variable), \(suggestedValue) \(error)")
			}
		}

		solver.updateVariables()

		// TODO: Find a more efficient way to do this. String region relies on this to calculate its size
		// Get new suggestions for edit variables for cases where edit variables depend on other edit variables
		for (variable, _, suggestedValue) in suggestedValues {
			do {
				//try solver.addEditVariable(variable: variable, strength: strength)
				try solver.suggestValue(variable: variable, value: suggestedValue)
			} catch {
				print("Error adding edit variable: \(variable), \(suggestedValue) \(error)")
			}
		}

		solver.updateVariables()
	}

	/**
	 This method will run the constraint solver on any children, updating their frames accordingly.
	 This method is useful if, for instance, you want to know what the size of something will be once
	 the constraints have been resolved.

	 Note: There is a performance penalty for running this, as a new constraint solver will be created.
	 */
	public func updateConstraints() {
		calculateConstraints()
		recursivelyUpdateFrames(transform: .zero)
	}

	internal func updateFrameFromConstraints(transformFromParent transform: CGPoint) {
		let frame = CGRect(x: CGFloat(left.value) - transform.x,
						   y: CGFloat(top.value) - transform.y,
						   width: CGFloat(width.value),
						   height: CGFloat(height.value))
		self.frame = frame
	}

	internal func recursivelyUpdateFrames(transform: CGPoint) {
		updateFrameFromConstraints(transformFromParent: transform)

		let newTransform = CGPoint(x: transform.x + frame.origin.x, y: transform.y + frame.origin.y)

		for child in children {
			child.recursivelyUpdateFrames(transform: newTransform)
		}
	}
}
