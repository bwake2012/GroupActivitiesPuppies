//
//  ViewController.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/10/21.
//

import UIKit
import GroupActivities

class ViewController: UIViewController {

    private var activityHandler: GroupActivityHandler?

    private var canConnect: Bool {

        return true // activityHandler?.canConnect ?? false
    }

    private var isConnected: Bool {

        return activityHandler?.isConnected ?? false
    }

    @IBOutlet var statusLabel: UILabel?
    
    @IBOutlet var connectButton: UIButton?

    @IBOutlet var displayImage: UIImageView?
    @IBOutlet var displayString: UILabel?

    @IBOutlet var puppyButtons: [UIButton]?

    @IBAction func connectTapped(_ sender: UIButton) {

        // sender.isHidden = canConnect

        if !isConnected {

            activityHandler?.activate()

        } else {

            activityHandler?.reset()
        }
    }

    @IBAction func sendPuppyTapped(_ sender: UIButton) {

        guard let puppyName = sender.accessibilityIdentifier else {

            preconditionFailure("Accessibility Identifier not defined for button tapped.")
        }

        activityHandler?.send(puppyName: puppyName)
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configurePuppyButtons()
        configureConnectButton()

        activityHandler = GroupActivityHandler(delegate: self)
        activityHandler?.handleSessions()
    }

}

extension ViewController: PuppyMessageDelegate {

    func connectionChanged() {

        DispatchQueue.main.async {

            self.configureConnectButton()
        }
    }

    func updatePuppy(name: String) {

        DispatchQueue.main.async {

            self.displayImage?.image = self.picture(for: name)
            self.displayString?.text = name
            self.statusLabel?.text = nil
        }
    }

    func report(error: PuppyError) {

        DispatchQueue.main.async {

            self.statusLabel?.text = error.localizedDescription
        }
    }

    private func picture(for puppyName: String) -> UIImage? {

            guard let url = Bundle.main.url(forResource: puppyName, withExtension: "png")
            else {
                preconditionFailure("No URL for \(puppyName).png")
            }

            guard let data = try? Data(contentsOf: url, options: .uncachedRead)
            else {
                preconditionFailure("No data from \(puppyName)")
            }

            guard let image = UIImage(data: data)
            else {
                preconditionFailure("Data from \(puppyName) is not an image.")
            }

            return image
        }

    private func configureConnectButton() {

        DispatchQueue.main.async {

            let name = self.isConnected ? "person.2.fill" : "person.2"
            let image = UIImage( systemName: name, compatibleWith: self.view.traitCollection)
            let text = self.isConnected ? "Disconnect" : "Connect"

            print("canConnect:\(self.canConnect) isConnected:\(self.isConnected) haveImage:\(nil == image ? false : true)")

            self.connectButton?.setImage(image, for: .normal)
            self.connectButton?.setTitle(text, for: .normal)
        }
    }

    private func configurePuppyButtons() {

        guard let puppyButtons = self.puppyButtons, !puppyButtons.isEmpty
        else {
            preconditionFailure("Puppy Buttons are not connected!")
        }

        for button in puppyButtons {

            button.imageView?.contentMode = .scaleAspectFit
        }
    }
}
