//
//  MainView.swift
//  sunRiseSet
//
//  Created by David Chester on 8/8/22.
//

import UIKit

class MainView: UIView {

    let sunshineBackround = UIImage(named: K.shared.sunshineBackground, in: Bundle.main, with: nil)
    let moonshineBackground = UIImage(named: K.shared.moonshineBackground, in: Bundle.main, with: nil)

    var sunModels = [SunModel]()
    //var sunURLS = [SunModelURL]()
    var sunTimesManager = SunTimesManager()


    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var dateButtons = [UIButton]()

    var locationButton: UIButton = {
        let locationButton = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: 28)
        locationButton.clipsToBounds = true
        locationButton.contentMode = .scaleAspectFit
        locationButton.setImage(UIImage(systemName: K.shared.locationButtonImage, withConfiguration: config), for: .normal)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        return locationButton
    }()

    var locationLabel: UILabel = {
        let locationLabel = UILabel()
        locationLabel.text = K.shared.locationLabel
        locationLabel.textColor = .gray
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont(name: K.shared.fontFutura, size: 18)
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        return locationLabel
    }()

    var currentUsersLocationLabel: UILabel = {
        let currentUsersLocationLabel = UILabel()
        currentUsersLocationLabel.text = ""
        currentUsersLocationLabel.textColor = .gray
        currentUsersLocationLabel.textAlignment = .center
        currentUsersLocationLabel.font = UIFont(name: K.shared.fontFutura, size: 18)
        currentUsersLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        return currentUsersLocationLabel
    }()

    var sunTableView: UITableView = {
        let sunTableView = UITableView()
        sunTableView.isScrollEnabled = false
        sunTableView.separatorStyle = .none
        sunTableView.backgroundColor = .clear
        sunTableView.allowsSelection = true
        sunTableView.translatesAutoresizingMaskIntoConstraints = false
        return sunTableView
    }()

    var dayLengthView: UIView = {
        let dayLengthView = UIView()
        dayLengthView.translatesAutoresizingMaskIntoConstraints = false
        dayLengthView.isHidden = true
        return dayLengthView
    }()

    var dayLengthTitle: UILabel = {
        let dayLengthTitle = UILabel()
        dayLengthTitle.text = K.shared.dayLength
        dayLengthTitle.textAlignment = .left
        dayLengthTitle.textColor = .gray
        dayLengthTitle.font = UIFont(name: K.shared.fontFutura, size: 24)
        dayLengthTitle.translatesAutoresizingMaskIntoConstraints = false
        return dayLengthTitle
    }()

    var dayLengthLabel: UILabel = {
        let dayLengthLabel = UILabel()
        dayLengthLabel.text = ""
        dayLengthLabel.textAlignment = .center
        dayLengthLabel.textColor = .darkGray
        dayLengthLabel.font = UIFont(name: K.shared.fontFutura, size: 24)
        dayLengthLabel.translatesAutoresizingMaskIntoConstraints = false
        return dayLengthLabel
    }()

    var buttonStack: UIStackView = {
        let buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
       buttonStack.isHidden = true
        buttonStack.spacing = 10
        return buttonStack
    }()


    // Create our buttons
    func createButtons(with title: String) -> UIButton {
        let dateButton = UIButton(type: .system)
        dateButton.setTitle(title, for: .normal)
        dateButton.titleLabel?.font = UIFont(name: K.shared.fontFutura, size: 22)
        dateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dateButton.addTarget(self, action: #selector(dateAdjust), for: .touchUpInside)
        return dateButton
    }

    @objc func dateAdjust(_ sender: UIButton) {
        deselectButton()
        sunTableView.reloadData()
        self.backgroundColor = UIColor(patternImage: sunshineBackround!)
        sender.isSelected = !sender.isSelected

        if sender.currentTitle == K.shared.sunTimesButtonTitle {
            self.backgroundColor = UIColor(patternImage: sunshineBackround!)
        } else if sender.currentTitle == K.shared.moonTimesButtonTitle {
            self.backgroundColor = UIColor(patternImage: moonshineBackground!)
        }
    }

    func setUpButton() {
        let dateArray =  [K.shared.sunTimesButtonTitle, K.shared.moonTimesButtonTitle]

        for dateTitle in dateArray {
            let button = createButtons(with: dateTitle)
            dateButtons.append(button)
            buttonStack.addArrangedSubview(button)
        }
    }

    func deselectButton () {
        dateButtons.forEach { UIButton in
            UIButton.isSelected = false
        }
    }


    func configure() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(patternImage: sunshineBackround!)

        setUpButton()

        self.addSubview(locationButton)
        self.addSubview(locationLabel)
        self.addSubview(buttonStack)
        self.addSubview(currentUsersLocationLabel)
        self.addSubview(sunTableView)

        dayLengthView.addSubview(dayLengthLabel)
        dayLengthView.addSubview(dayLengthTitle)

        self.addSubview(dayLengthView)

        NSLayoutConstraint.activate([

            locationButton.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor, constant: 10),
            locationButton.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -20),

            locationLabel.topAnchor.constraint(equalTo: locationButton.topAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -15),
            locationLabel.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),

            buttonStack.topAnchor.constraint(lessThanOrEqualTo: locationButton.bottomAnchor, constant: 70),
            buttonStack.widthAnchor.constraint(equalTo: self.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            buttonStack.heightAnchor.constraint(equalToConstant: 50),
            buttonStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            currentUsersLocationLabel.bottomAnchor.constraint(equalTo: sunTableView.topAnchor, constant: 20),
            currentUsersLocationLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            sunTableView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
            sunTableView.widthAnchor.constraint(equalTo: self.layoutMarginsGuide.widthAnchor, multiplier: 0.8),
            sunTableView.heightAnchor.constraint(equalTo: self.layoutMarginsGuide.heightAnchor, multiplier: 0.3),
            sunTableView.centerXAnchor.constraint(equalTo: self.centerXAnchor),

            dayLengthTitle.topAnchor.constraint(equalTo: dayLengthView.topAnchor),
            dayLengthTitle.leadingAnchor.constraint(equalTo: dayLengthView.leadingAnchor),

            dayLengthLabel.bottomAnchor.constraint(equalTo: dayLengthView.bottomAnchor),
            dayLengthLabel.centerXAnchor.constraint(equalTo: dayLengthView.centerXAnchor),

            dayLengthView.topAnchor.constraint(equalTo: sunTableView.bottomAnchor, constant: 30),
            dayLengthView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dayLengthView.heightAnchor.constraint(equalTo: self.layoutMarginsGuide.heightAnchor, multiplier: 0.1),
            dayLengthView.widthAnchor.constraint(equalTo: self.layoutMarginsGuide.widthAnchor, multiplier: 0.6)
        ])
    }
}
