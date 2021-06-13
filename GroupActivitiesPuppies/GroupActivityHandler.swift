//
//  GroupActivityHandler.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/12/21.
//

import Foundation
import Combine
import GroupActivities

enum PuppyError: Error {

    case messageSendFail(Error)
    case messageCatchupSendFail(Error)

    var localizedDescription: String {

        switch self {
        case .messageSendFail(let error):
            return "Choose Puppy message send failure: \(error.localizedDescription)"
        case .messageCatchupSendFail(let error):
            return "Choose Puppy catchup message send failure: \(error.localizedDescription)"
        }
    }
}

protocol PuppyMessageDelegate: AnyObject {

    func connectionChanged()
    func updatePuppy(name: String)
    func report(error: PuppyError)
}

class GroupActivityHandler: NSObject {

    var groupStateObserver = GroupStateObserver()
    var isEligibleForGroupSession: Bool = false

    weak var delegate: PuppyMessageDelegate?

    var canConnect: Bool {

        return self.isEligibleForGroupSession
    }

    var isConnected: Bool {

        return nil != groupSession
    }

    var tasks = Set<Task.Handle<(), Never>>()

    var messenger: GroupSessionMessenger?

    var groupSession: GroupSession<ChoosePuppyActivity>?

    var latestMessage: ChoosePuppyMessage?

    var subscriptions = Set<AnyCancellable>()

    var activity: ChoosePuppyActivity?

    init(delegate: PuppyMessageDelegate) {

        super.init()

        self.delegate = delegate

        groupStateObserver.$isEligibleForGroupSession.sink { [weak self] isElegibleForGroupSession in

            self?.delegate?.connectionChanged()
        }
        .store(in: &subscriptions)
    }

    func activate() {

        activity = ChoosePuppyActivity()

        activity?.activate()
    }

    func reset() {

        latestMessage = nil

        // tear down existing group session
        messenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []

        groupSession?.leave()
        groupSession = nil
        activate()
    }

    func handleSessions() {

        async {

            for await session in ChoosePuppyActivity.sessions() {

                configureGroupSession(session)
            }
        }
    }

    func configureGroupSession(_ session: GroupSession<ChoosePuppyActivity>) {

        groupSession = session

        subscriptions.removeAll()

        groupSession?.$state.sink { [weak self] state in

            if case .invalidated = state {

                self?.groupSession = nil
                self?.subscriptions.removeAll()
            }
        }
        .store(in: &subscriptions)

        groupSession?.$activeParticipants
            .sink { activeParticipants in

                guard
                    let activeParticipants = self.groupSession?.activeParticipants
                else { return }

                let newParticipants = activeParticipants.subtracting(activeParticipants)

                if let name = self.latestMessage?.puppyName {

                    async {
                        do {

                            try await self.messenger?.send(
                                ChoosePuppyMessage(puppyName: name),
                                to: .only(newParticipants))

                        } catch {

                            self.delegate?.report(error: .messageCatchupSendFail(error))
                        }
                    }
                }
             }
            .store(in: &subscriptions)

        session.join()

        self.messenger = GroupSessionMessenger(session: session)

        configureMessenger()

        delegate?.connectionChanged()
    }

    func configureMessenger() {

        let puppyTask = detach { [weak self] in

            guard let messenger = self?.messenger else { return }

            for await (message, _) in messenger.messages(of: ChoosePuppyMessage.self) {

                self?.handle(message)
            }
        }

        tasks.insert(puppyTask)
    }

    func handle(_ message: ChoosePuppyMessage) {

        if latestMessage?.timestamp ?? Date.distantPast < message.timestamp {

            latestMessage = message
            delegate?.updatePuppy(name: message.puppyName)
        }

    }

    func send(puppyName: String) {

        guard nil != messenger else { return }

        async {

            do {

                try await messenger?.send(ChoosePuppyMessage(puppyName: puppyName))

            } catch {

                delegate?.report(error: .messageSendFail(error))
            }
        }
    }
}
