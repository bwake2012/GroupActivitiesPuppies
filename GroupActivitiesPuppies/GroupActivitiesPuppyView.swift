// GroupActivitiesPuppyView.swift
//
// Created by Bob Wakefield on 12/13/24.
// for GroupActivitiesPuppies
//
// Using Swift 6.0
// Running on macOS 15.1

import UIKit

class GroupActivitiesPuppyView: UIView {

    #if os(visionOS)
    private let topPadding: CGFloat = 32
    private let bottomPadding: CGFloat = 32
    private let minTouchTargetWidth: CGFloat = 60
    private let minTouchTargetHeight: CGFloat = 60
    #else
    private let topPadding: CGFloat = 0
    private let bottomPadding: CGFloat = 0
    private let minTouchTargetWidth: CGFloat = 44
    private let minTouchTargetHeight: CGFloat = 44
    #endif

    let leftPadding: CGFloat = 16
    let rightPadding: CGFloat = 16
    let verticalSpacing: CGFloat = 8

    override init(frame: CGRect) {

        super.init(frame: frame)

        setup(view: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // <------------- UI Elements --------------->

    private lazy var mainTitleLabel: UILabel = buildLabel(text: "Group Activities Puppies", style: .title1, alignment: .center)

    private lazy var scrollEnvelope: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    private func buildLabel(text: String, style: UIFont.TextStyle = .body, alignment: NSTextAlignment = .natural) -> UILabel {
        let label = UILabel()
        label.contentMode = .left
        label.text = text
        label.textAlignment = alignment
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontForContentSizeCategory = true
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.font = .preferredFont(forTextStyle: style)
        return label
    }

    lazy var statusLabel: UILabel = buildLabel(text: "Normal")

    private lazy var copyrightLabel: UILabel = buildLabel(text: "2024 Cockleburr Software", alignment: .center)

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isMultipleTouchEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var scrollContents: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()

    private lazy var dogButtonStack: UIStackView = {
        let stackView = UIStackView()
        stackView.contentMode = .scaleAspectFit
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.distribution = .fillEqually
        stackView.alignment = .top
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    lazy var currentDogImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setContentCompressionResistancePriority(.required, for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var currentDogLabel: UILabel = buildLabel(text: "No Puppy Selected", alignment: .center)

    lazy var connectButton: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleToFill
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration = .plain()
        button.setTitle("Connect", for: .normal)
        return button
    }()

    private func buildDogButton(imageName: String, title: String) -> UIButton {
        let button = UIButton()
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .top
        button.adjustsImageSizeForAccessibilityContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = .preferredFont(forTextStyle: .body)
        button.imageView?.contentMode = .scaleAspectFit
        if let url = Bundle.main.url(forResource: imageName, withExtension: "png"),
           let data = try? Data(contentsOf: url, options: .uncachedRead),
           let image = UIImage(data: data) {

            button.setImage(image, for: .normal)
        }
        button.isAccessibilityElement = true
        button.accessibilityIdentifier = imageName
        button.accessibilityLabel = title

        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: minTouchTargetWidth),
            button.heightAnchor.constraint(equalToConstant: minTouchTargetHeight),
          ])

        return button
    }

    private lazy var buttonDog1: UIButton =
        buildDogButton(imageName: "AmericanEskimo", title: "American Eskimo")

    private lazy var buttonDog2: UIButton =
        buildDogButton(imageName: "AnnaAvatar", title: "Anna Avatar")

    private lazy var buttonDog3: UIButton =
        buildDogButton(imageName: "Boo", title: "Boo")

    private lazy var buttonDog4: UIButton =
        buildDogButton(imageName: "Buddy", title: "Buddy")

    private lazy var buttonDog5: UIButton =
        buildDogButton(imageName: "corgi", title: "Corgi")

    private lazy var buttonDog6: UIButton =
        buildDogButton(imageName: "Pontus", title: "Pontus")

    private lazy var buttonDog7: UIButton =
        buildDogButton(imageName: "SnowyTricolorSheltie", title: "Snowy Tricolor Sheltie")

    private lazy var buttonDog8: UIButton =
        buildDogButton(imageName: "Buddy2 Small", title: "Buddy2")

    lazy var dogButtons: [UIButton] = [
        buttonDog1, buttonDog2, buttonDog3, buttonDog4, buttonDog5, buttonDog6, buttonDog7, buttonDog8
    ]

    // <------------- View Hierachy --------------->

    func addSubviews(to view: UIView) {

        view.addSubview(mainTitleLabel)
        view.addSubview(copyrightLabel)
        view.addSubview(scrollEnvelope)
        view.addSubview(statusLabel)

        scrollEnvelope.addSubview(scrollView)

        scrollView.addSubview(scrollContents)

        scrollContents.addSubview(dogButtonStack)
        scrollContents.addSubview(currentDogImageView)
        scrollContents.addSubview(currentDogLabel)
        scrollContents.addSubview(connectButton)

        dogButtonStack.addArrangedSubview(buttonDog1)
        dogButtonStack.addArrangedSubview(buttonDog2)
        dogButtonStack.addArrangedSubview(buttonDog3)
        dogButtonStack.addArrangedSubview(buttonDog4)
        dogButtonStack.addArrangedSubview(buttonDog5)
        dogButtonStack.addArrangedSubview(buttonDog6)
        dogButtonStack.addArrangedSubview(buttonDog7)
        dogButtonStack.addArrangedSubview(buttonDog8)
    }

    // <------------- Constrains --------------->

    func addConstraints(to view: UIView) {

        NSLayoutConstraint.activate([
            mainTitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: topPadding),
            mainTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: mainTitleLabel.trailingAnchor),

            copyrightLabel.topAnchor.constraint(equalTo: mainTitleLabel.bottomAnchor, constant: verticalSpacing),
            copyrightLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            copyrightLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollEnvelope.topAnchor.constraint(equalTo: copyrightLabel.bottomAnchor, constant: verticalSpacing),
            scrollEnvelope.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftPadding),
            view.trailingAnchor.constraint(equalTo: scrollEnvelope.trailingAnchor, constant: rightPadding),

            statusLabel.topAnchor.constraint(equalTo: scrollEnvelope.bottomAnchor, constant: verticalSpacing),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leftPadding),
            view.trailingAnchor.constraint(equalTo: statusLabel.trailingAnchor, constant: rightPadding),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: bottomPadding),

            scrollView.topAnchor.constraint(equalTo: scrollEnvelope.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: scrollEnvelope.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: scrollEnvelope.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: scrollEnvelope.trailingAnchor),

            scrollContents.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContents.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollContents.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContents.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContents.widthAnchor.constraint(equalTo: scrollEnvelope.widthAnchor),
            scrollContents.heightAnchor.constraint(greaterThanOrEqualTo: scrollEnvelope.heightAnchor),

            dogButtonStack.topAnchor.constraint(equalTo: scrollContents.topAnchor),
            dogButtonStack.leadingAnchor.constraint(equalTo: scrollContents.leadingAnchor),
            dogButtonStack.centerXAnchor.constraint(equalTo: scrollContents.centerXAnchor),

            currentDogImageView.topAnchor.constraint(equalTo: dogButtonStack.bottomAnchor, constant: verticalSpacing),
            currentDogImageView.leadingAnchor.constraint(greaterThanOrEqualTo: scrollContents.leadingAnchor),
            scrollContents.trailingAnchor.constraint(greaterThanOrEqualTo: currentDogImageView.trailingAnchor),
            currentDogImageView.centerXAnchor.constraint(equalTo: scrollContents.centerXAnchor),

            currentDogLabel.topAnchor.constraint(equalTo: currentDogImageView.bottomAnchor, constant: verticalSpacing),
            currentDogLabel.leadingAnchor.constraint(equalTo: scrollContents.leadingAnchor),
            currentDogLabel.trailingAnchor.constraint(equalTo: scrollContents.trailingAnchor),

            connectButton.topAnchor.constraint(greaterThanOrEqualTo: currentDogLabel.bottomAnchor, constant: verticalSpacing),
            scrollContents.bottomAnchor.constraint(equalTo: connectButton.bottomAnchor, constant: verticalSpacing),
            connectButton.leadingAnchor.constraint(equalTo: scrollContents.leadingAnchor),
            scrollContents.trailingAnchor.constraint(equalTo: connectButton.trailingAnchor),
        ])
    }

    // <------------- Base View Properties --------------->

    func setup(view: UIView) {

        addSubviews(to: view)
        addConstraints(to: view)

        view.backgroundColor = .systemBackground
        statusLabel.backgroundColor = .secondarySystemBackground
    }

}
