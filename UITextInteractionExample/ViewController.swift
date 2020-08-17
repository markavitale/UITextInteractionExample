// Licensed under the MIT License.

import UIKit

class ViewController: UIViewController {
	/// Our text label
	let customTextLabel = CustomTextLabel(labelText: ViewController.initialText)
	
	/// A switch for toggling between
	let interactionModeSwitch = UISwitch()
	
	var interaction: UITextInteraction?

	override func loadView() {
		view = UIView(frame: .zero)
		
		// Make a button to rotate the text
		let rotateButton = UIButton(type: .roundedRect)
		rotateButton.setTitle("Rotate", for: .normal)
		rotateButton.addTarget(self, action: #selector(rotateTextLabel), for: .touchUpInside)
		
		// Make a switch to toggle interaction mode
		let interactionModeLabel = UILabel()
		interactionModeLabel.text = "Editable"
		interactionModeSwitch.addTarget(self, action: #selector(updateInteractionMode), for: .valueChanged)
		interactionModeSwitch.setOn(true, animated: false)
		let interactionModeStackView = UIStackView(arrangedSubviews: [interactionModeLabel, interactionModeSwitch])
		interactionModeStackView.spacing = 10.0
		
		// Put our modifier controls into a stack view
		let labelModifierControls = UIStackView(arrangedSubviews: [
			rotateButton,
			interactionModeStackView
		])
		labelModifierControls.translatesAutoresizingMaskIntoConstraints = false
		labelModifierControls.axis = .vertical
		labelModifierControls.alignment = .leading
		view.addSubview(labelModifierControls)
		
		// Make a scroll view to contain our UITextInteraction
		let scrollView = UIScrollView(frame: .zero)
		scrollView.contentSize = customTextLabel.intrinsicContentSize
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		
		// Add the CustomTextLabel as a subview of our scrollview
		customTextLabel.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(customTextLabel)
		
		view.addSubview(scrollView)
		
		NSLayoutConstraint.activate([
			labelModifierControls.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
			labelModifierControls.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 200),
			scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 200),
			scrollView.widthAnchor.constraint(equalToConstant: 300),
			scrollView.heightAnchor.constraint(equalToConstant: 150),
			customTextLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			customTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
			customTextLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			customTextLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
		])
		
		updateInteractionMode()
	}
	
	/// Rotate the text label by 45 degrees
	@objc func rotateTextLabel() {
		// Transform the label by rotating pi/4 radians
		customTextLabel.transform = customTextLabel.transform.concatenating(CGAffineTransform(rotationAngle: .pi / 8))
	}
	
	/// Toggle whether we should be using a
	@objc func updateInteractionMode() {
		if let oldInteraction = interaction {
			view.removeInteraction(oldInteraction)
		}
		
		// Add UITextInteraction based on the customTextLabel
		let newInteraction = UITextInteraction(for: interactionModeSwitch.isOn ? .editable : .nonEditable)
		newInteraction.textInput = customTextLabel
		view.addInteraction(newInteraction)
		interaction = newInteraction
	}
	
	/// The initial text to populate our `CustomTextLabel`
	private static let initialText = """
	Sphinx of black quartz, judge my vow.
	Pack my box with five dozen liquor jugs.
	A quick brown fox jumps over the lazy dog.
	A quart jar of oil mixed with zinc oxide makes a very bright paint.
	The five boxing wizards jump quickly.
	Sphinx of black quartz, judge my vow.
	Pack my box with five dozen liquor jugs.
	A quick brown fox jumps over the lazy dog.
	A quart jar of oil mixed with zinc oxide makes a very bright paint.
	The five boxing wizards jump quickly.
	"""
}

