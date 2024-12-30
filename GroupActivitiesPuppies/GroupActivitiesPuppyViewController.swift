//
//  GroupActivitiesPuppyViewController.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/10/21.
//

import UIKit
import GroupActivities

class GroupActivitiesPuppyViewController: UIViewController {

    private var activityHandler: GroupActivityHandler<ChoosePuppyActivity, ChoosePuppyMessage>?

    private var canConnect: Bool {

        activityHandler?.canConnect ?? false
    }

    private var isConnected: Bool {

        activityHandler?.isConnected ?? false
    }

    private var participantCount: Int {

        activityHandler?.participantCount ?? 0
    }

    var puppyView: GroupActivitiesPuppyView?

    var eligibilityStatusLabel: UILabel? {
        puppyView?.eligibilityStatusLabel
    }

    var sessionStatusLabel: UILabel? {
        puppyView?.sessionStatusLabel
    }

    var participantsStatusLabel: UILabel? {
        puppyView?.participantsStatusLabel
    }

    var generalStatusLabel: UILabel? {
        puppyView?.generalStatusLabel
    }

    var connectButton: UIButton? {
        puppyView?.connectButton
    }

    var displayImage: UIImageView? {
        puppyView?.currentDogImageView
    }

    var displayString: UILabel? {
        puppyView?.currentDogLabel
    }

    var refreshButton: UIButton? {
        puppyView?.refreshButton
    }

    var puppyButtons: [UIButton] = []

    @objc func connectTapped(_ sender: UIButton) {

        if !isConnected {

            activityHandler?.activate()
        }
    }

    @objc func refreshTapped(_ sender: UIButton) {

        DispatchQueue.main.async {
            self.participantsStatusLabel?.text = "Participants: \(self.participantCount)"
            self.eligibilityStatusLabel?.text = self.canConnect ? "Eligible" : "Not eligible"
            self.sessionStatusLabel?.text = self.isConnected ? "Connected" : "Not connected"
            self.connectButton?.isEnabled = self.canConnect && !self.isConnected
        }
    }

    @objc func sendPuppyTapped(_ sender: UIButton) {

        guard let fileName = sender.accessibilityIdentifier else {

            preconditionFailure("Accessibility Identifier not defined for button tapped.")
        }

        let title = sender.accessibilityLabel ?? "No title"

        activityHandler?.send(message: ChoosePuppyMessage(fileName: fileName, title: title))

        print("Button tapped: \(title)")
    }

    override func loadView() {
        puppyView = GroupActivitiesPuppyView(frame: .zero)

        puppyView?.connectButton.addTarget(self, action: #selector(self.connectTapped(_ :)), for: .touchUpInside)
        puppyButtons = puppyView?.dogButtons.compactMap {
            $0.addTarget(self, action: #selector(self.sendPuppyTapped(_:)), for: .touchUpInside)

            return $0
        } ?? []
        puppyView?.refreshButton.addTarget(self, action: #selector(refreshTapped), for: .touchUpInside)

        self.view = puppyView
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureConnectButton()

        activityHandler = GroupActivityHandler(activity: ChoosePuppyActivity(), delegate: self)
        activityHandler?.beginWaitingForSessions()
    }
}

extension GroupActivitiesPuppyViewController: GroupActivityHandlerDelegate {

    func stateChanged() {

        DispatchQueue.main.async {

            self.configureConnectButton()

            if let refreshButton = self.refreshButton {
                self.refreshTapped(refreshButton)
            }
        }
    }

    func update<M: GroupActivityMessage>(message: M) {

        // make certain the message is the right type
        guard let message = message as? ChoosePuppyMessage else {

            preconditionFailure("Updated with a GroupActivityMessage that is not a ChoosePuppyMessage!")
        }

        DispatchQueue.main.async {

            self.displayImage?.image = self.picture(for: message.fileName)
            self.displayString?.text = message.title
            self.generalStatusLabel?.text = nil
            self.connectButton?.isEnabled = !self.isConnected
        }
    }

    func report(error: Error) {

        DispatchQueue.main.async {

            self.generalStatusLabel?.text = error.localizedDescription
        }
    }

    private func picture(for puppyName: String) -> UIImage? {

        guard let url = Bundle.main.url(forResource: puppyName, withExtension: "png")
        else {
            generalStatusLabel?.text = "No URL for \(puppyName).png"
            return nil
        }

        guard let data = try? Data(contentsOf: url, options: .uncachedRead)
        else {
            generalStatusLabel?.text = "No data from \(puppyName)"
            return nil
        }

        guard let image = UIImage(data: data)
        else {
            generalStatusLabel?.text = "Data from \(puppyName) is not an image."
            return nil
        }

        return image
    }

    private func configureConnectButton() {

        DispatchQueue.main.async {

            let name = self.isConnected ? "person.2.fill" : "person.2"
            let image = UIImage( systemName: name, compatibleWith: self.view.traitCollection)
            let text = self.isConnected ? "Disconnect" : "Connect"

            print("canConnect:\(self.canConnect) isConnected:\(self.isConnected)")

            self.connectButton?.setImage(image, for: .normal)
            self.connectButton?.setTitle(text, for: .normal)

            self.connectButton?.isEnabled = self.canConnect && !self.isConnected
        }
    }
}
