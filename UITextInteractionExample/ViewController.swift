// Licensed under the MIT License.

import UIKit

class ViewController: UIViewController {
	private static let initialText = """
	Sphinx of black quartz, judge my vow.
	Pack my box with five dozen liquor jugs.
	"""

	override func loadView() {
		view = UIView(frame: .zero)
		
		// Create a custom text label and add it as a subview
		let customTextLabel = CustomTextLabel(labelText: ViewController.initialText)
		customTextLabel.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(customTextLabel)
		
		NSLayoutConstraint.activate([
			customTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
			customTextLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
		])
		
		// Add UITextInteraction based on the customTextLabel
		let interaction = UITextInteraction(for: .editable)
		interaction.textInput = customTextLabel
		view.addInteraction(interaction)
		
	}


}

