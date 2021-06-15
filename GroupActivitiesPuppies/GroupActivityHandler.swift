//
//  GroupActivityHandler.swift
//  GroupActivitiesPuppies
//
//  Created by Bob Wakefield on 6/12/21.
//

import Foundation
import Combine
import GroupActivities

protocol GroupActivityMessage: Codable {

    var id: UUID { get }
    var timestamp: Date { get }

    init?(payload: GroupActivityMessage)
}

protocol GroupActivityHandlerDelegate: AnyObject {

    func connectionChanged()
    func update<M: GroupActivityMessage>(message: M)
    func report(error: Error)
}

/// Contains the setup and session logic for GroupActivities.
class GroupActivityHandler<GA: GroupActivity, GM: GroupActivityMessage>: NSObject {

    enum GroupActivityHandlerError: Error {

        case messageSendFail(Error)
        case messageCatchupSendFail(Error)

        var localizedDescription: String {

            switch self {
            case .messageSendFail(let error):
                return "Activity message send failure: \(error.localizedDescription)"
            case .messageCatchupSendFail(let error):
                return "Activity catchup message send failure: \(error.localizedDescription)"
            }
        }
    }

    private var groupStateObserver = GroupStateObserver()
    var isEligibleForGroupSession: Bool = false

    private weak var delegate: GroupActivityHandlerDelegate?

    var canConnect: Bool {

        return self.isEligibleForGroupSession
    }

    var isConnected: Bool {

        return nil != groupSession
    }

    var participantCount: Int {

        return groupSession?.activeParticipants.count ?? 0
    }

    private var tasks = Set<Task.Handle<(), Never>>()

    private var messenger: GroupSessionMessenger?

    private var groupSession: GroupSession<GA>?

    private var activeParticipants: Set<Participant> = []

    private var latestMessage: GM?

    private var subscriptions = Set<AnyCancellable>()

    private var activity: GA?

    /// Create the activity handler, and set up an observer
    /// for whether or not we have a FaceTime connection.
    init(activity: GA, delegate: GroupActivityHandlerDelegate) {

        super.init()

        self.activity = activity
        self.delegate = delegate

        groupStateObserver.$isEligibleForGroupSession.sink { [weak self] isElegibleForGroupSession in

            self?.delegate?.connectionChanged()
        }
        .store(in: &subscriptions)
    }

    func activate() {

        activity?.activate()

        self.delegate?.connectionChanged()
    }

    func reset() {

        latestMessage = nil

        // tear down existing group session
        teardown()

        groupSession?.leave()
        groupSession = nil

        delegate?.connectionChanged()
    }

    private func teardown() {

        messenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
    }

    /// Wait for sessions to connect
    func beginWaitingForSessions() {

        async {

            for await session in GA.sessions() {

                configureGroupSession(session)
            }
        }
    }

    private func configureGroupSession(_ session: GroupSession<GA>) {

        groupSession = session

        subscriptions.removeAll()

        groupSession?.$state.sink { [weak self] state in

            if case .invalidated = state {

                self?.teardown()

                self?.delegate?.connectionChanged()
            }
        }
        .store(in: &subscriptions)

        groupSession?.$activeParticipants
            .sink { activeParticipants in

                // if we don't have a latest message we don't need to update anybody
                guard let latestMessage = self.latestMessage, let catchupMessage = GM(payload: latestMessage) else { return }

                let newParticipants = activeParticipants.subtracting(self.activeParticipants)

                if !newParticipants.isEmpty {

                    async {

                        do {

                            try await self.messenger?.send(catchupMessage, to: .only(newParticipants))

                        } catch {

                            self.delegate?.report(error: GroupActivityHandlerError.messageCatchupSendFail(error))
                        }
                    }
                }

                self.activeParticipants = activeParticipants

                self.delegate?.connectionChanged()
            }
            .store(in: &subscriptions)

        session.join()

        self.messenger = GroupSessionMessenger(session: session)

        configureMessenger()

        delegate?.connectionChanged()
    }

    /// Add a task to wait for messages for other devices in the session
    /// and pass them on to the delegate.
    private func configureMessenger() {

        let task = detach { [weak self] in

            guard let messenger = self?.messenger else { return }

            for await (message, _) in messenger.messages(of: GM.self) {

                self?.handle(message)
            }
        }

        tasks.insert(task)
    }

    /// Forward a message from another device in the session to the delegate. Do
    /// not forward messages which have passed their sell-by date.
    /// - Parameter message: Message received from the other device. Must conform
    /// to the GroupActivityMessage protocol, with a unique ID and timestamp.
    private func handle(_ message: GM) {

        if latestMessage?.timestamp ?? Date.distantPast < message.timestamp {

            latestMessage = message
            delegate?.update(message: message)
        }
    }

    /// Pass a message to the other devices in this session. Report any error to the delegate.
    /// - Parameter message: The structure to be passed.
    func send(message: GM) {

        guard nil != messenger else { return }

        async {

            do {

                try await messenger?.send(message)

            } catch {

                delegate?.report(error: GroupActivityHandlerError.messageSendFail(error))
            }
        }
    }
}
