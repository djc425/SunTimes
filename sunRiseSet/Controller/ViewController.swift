//
//  ViewController.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    var sunModels = [SunModel]()
    var sunURLS = [SunModelURL]()
    var sunTimesManager = SunTimesManager()

    
    // location button
   // let buttonRect = CGRect(x: 0, y: 0, width: 100, height: 100)
    let config = UIImage.SymbolConfiguration(pointSize: 28)
    var locationButtonImage: UIImage!
    let locationButton = UIButton(type: .custom)
    
    // locate me label
    var locationLabel: UILabel!
    
    // Datelabel
    let currentView = UIView()

    // Today/Tomorrow button stack
    var dateButtons = [UIButton]()
    let buttonStack = UIStackView()
    
    // userLocation label
    var currentUsersLocationLabel: UILabel!
    
    // sunrise tableview
    let sunTableView = UITableView()
    
    // daylength view and label
    var dayLengthView = UIView()
    var dayLengthTitle: UILabel!
    var dayLengthLabel: UILabel!
    
    //background images
   let sunshineBackround = UIImage(named: "sunshine.png", in: Bundle.main, with: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // delegates and datasource
        sunTableView.delegate = self
        sunTableView.dataSource = self
        sunTimesManager.delegate = self
       
        //location manager delegate and auth request
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self

        // registering custom cell
        sunTableView.register(SunCell.self, forCellReuseIdentifier: SunCell.identifier)

        
    }
    // MARK: pressed button
    @objc func userPressedLocationButton()  {
        sunModels.removeAll()
        sunTableView.reloadData()
        locationLabel.isHidden = true
        dateButtons[0].isSelected = true
        dateButtons[1].isSelected = false
        if locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            print("updating location")
        } else if locationManager.authorizationStatus == .denied {
            locationManager.requestWhenInUseAuthorization()
        }

            
        locationManager.stopUpdatingLocation()

    }
    
    @objc func dateAdjust(_ sender: UIButton) {
        deselectButton()
        view.backgroundColor = UIColor(patternImage: sunshineBackround!)
        sender.isSelected = !sender.isSelected
        
        let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "y-MM-dd"
        let today = dateFormatter.string(from: Date.today)
        let tomorrow = dateFormatter.string(from: Date.tomorrow)
       
        let longitude = sunURLS[0].long
        let lat = sunURLS[0].lat
       
        if sender.currentTitle == "Today" {
            sunTimesManager.sunTimesURLGenerator(lat: lat, long: longitude, date: today)
            print(today)
        } else if sender.currentTitle == "Tomorrow"{
            sunTimesManager.sunTimesURLGenerator(lat: lat, long: longitude, date: tomorrow)
            print(tomorrow)
        }
        sunModels.removeAll()
    }
}



// MARK: suntimes Manager delegate
extension ViewController: SunTimesManagerDelegate {
    func didUpdateTimes(sunManager: SunTimesManager, sunTimes: [SunModel]) {
        
        DispatchQueue.main.async {
            self.buttonStack.isHidden = false
            self.dayLengthView.isHidden = false
            self.sunModels.append(contentsOf: sunTimes)
            print(self.sunModels)
            self.dayLengthLabel.text = self.sunModels[0].dayLength
            self.sunTableView.reloadData()
        }
    }
    

    func didFailWithError(error: Error) {
        print(error)
        
    }
}


// MARK: TableView DataSource & delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sunTableView.frame.height / 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sunModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // in case our cell can't load we call on a default tableview cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SunCell.identifier, for: indexPath) as? SunCell else {
            return UITableViewCell()
        }
        
        let currentSunInfo = sunModels[indexPath.section]
        cell.sunInfo = currentSunInfo
        cell.backgroundColor = .clear
        let bgView = UIView()
        bgView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        bgView.layer.opacity = 0.2
        cell.selectedBackgroundView = bgView
       // print("Cell created")
        
        return cell
    }
        
  
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sunTableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "peaches.png", in: Bundle.main, with: nil)!)
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(named: "sunset.png", in: Bundle.main, with: nil)!)
        }
        
        
  
    }
    
    

}

// MARK: Location Manager Methods
extension ViewController: CLLocationManagerDelegate {

     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         print("is this getting called")
        guard let userLocation = locations.first else { return }
        print(userLocation.coordinate)
        locationManager.stopUpdatingLocation()
        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y-MM-dd"
        let today = dateFormatter.string(from: date)
        print(today)
        
        let location = SunModelURL(dateURL: today, lat: lat, long: long)
         
         sunURLS.append(location)
         print(sunURLS)
         showLocation(lat: lat, long: long)
         
        sunTimesManager.sunTimesURLGenerator(lat: lat, long: long, date: today)
         print("intial suntime")
        //placeHolderData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let alert =  UIAlertController(title: "An error has occured", message: error.localizedDescription, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        
        present(alert, animated: true)
    }
    
    func showLocation(lat: Double, long: Double) {
        let geoCoder = CLGeocoder()
        
        geoCoder.reverseGeocodeLocation(CLLocation(latitude: lat, longitude: long)) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            guard let placemarks = placemarks?.first else {
                let alert = UIAlertController(title: "An error has occured", message: error?.localizedDescription, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
                
                self.present(alert, animated: true)
                return
            }
            
            let city = placemarks.locality ?? ""
            let state = placemarks.administrativeArea ?? ""
            
            DispatchQueue.main.async {
               
                if city == "" {
                    self.currentUsersLocationLabel.text = "\(state)"
                } else  {
                    self.currentUsersLocationLabel.text = "\(city), \(state)"
                }
                
            }
        }
        
    }
    
}

// MARK: Date Extension
extension Date {
            
   static var tomorrow:  Date { return Date().dayAfter }
   static var today: Date {return Date()}
   var dayAfter: Date {
      return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
   }
}

// MARK: LoadView + button creation Extension
extension ViewController {
    
    // Create our buttons
    func createButtons(with title: String) -> UIButton {
        let dateButton = UIButton(type: .system)
        dateButton.setTitle(title, for: .normal)
        dateButton.titleLabel?.font = UIFont(name: "futura", size: 24)
        dateButton.titleLabel?.adjustsFontSizeToFitWidth = true
        dateButton.addTarget(self, action: #selector(dateAdjust), for: .touchUpInside)
        return dateButton
    }
    
    func setUpButton() {
        let dateArray =  ["Today", "Tomorrow"]
        
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
   
        override func loadView() {
            view = UIView()
            view.backgroundColor = UIColor(patternImage: sunshineBackround!)
            
            setUpButton()
            
            // MARK: location button settings
            locationButtonImage = UIImage(systemName: "location.circle.fill", withConfiguration: config)
            locationButton.clipsToBounds = true
            locationButton.contentMode = .scaleAspectFit
            locationButton.setImage(locationButtonImage, for: .normal)
            locationButton.addTarget(self, action: #selector(userPressedLocationButton), for: .touchUpInside)
            locationButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(locationButton)
            
            locationLabel = UILabel()
            locationLabel.text = "Locate Yourself"
            locationLabel.textColor = .gray
            locationLabel.textAlignment = .center
            locationLabel.font = UIFont(name: "futura", size: 18)
            locationLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(locationLabel)
            
            //MARK: dateButtons / buttonstack settings
            dateButtons[0].isSelected = true
            buttonStack.translatesAutoresizingMaskIntoConstraints = false
           buttonStack.isHidden = true
            buttonStack.spacing = 10
            view.addSubview(buttonStack)
            
            // MARK: current location label
            currentUsersLocationLabel = UILabel()
            currentUsersLocationLabel.text = ""
            currentUsersLocationLabel.textColor = .gray
            currentUsersLocationLabel.textAlignment = .center
            currentUsersLocationLabel.font = UIFont(name: "futura", size: 18)
            currentUsersLocationLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(currentUsersLocationLabel)
            
            //MARK: SunTable UITableView
            sunTableView.isScrollEnabled = false
            sunTableView.separatorStyle = .none
            sunTableView.backgroundColor = .clear
            sunTableView.translatesAutoresizingMaskIntoConstraints = false
          // sunTableView.estimatedRowHeight = 75
          //  sunTableView.rowHeight = UITableView.automaticDimension
            view.addSubview(sunTableView)
            
            //MARK: Day Length Label
            dayLengthTitle = UILabel()
            dayLengthTitle.text = "Day length:"
            dayLengthTitle.textAlignment = .left
            dayLengthTitle.textColor = .gray
            dayLengthTitle.font = UIFont(name: "futura", size: 24)
            dayLengthTitle.translatesAutoresizingMaskIntoConstraints = false
            dayLengthView.addSubview(dayLengthTitle)
            
            dayLengthLabel = UILabel()
            dayLengthLabel.text = ""
            dayLengthLabel.textAlignment = .center
            dayLengthLabel.textColor = .darkGray
            dayLengthLabel.font = UIFont(name: "futura", size: 24)
            dayLengthLabel.translatesAutoresizingMaskIntoConstraints = false
            dayLengthView.addSubview(dayLengthLabel)
            
            dayLengthView.translatesAutoresizingMaskIntoConstraints = false
            dayLengthView.isHidden = true
            view.addSubview(dayLengthView)

            
            // MARK: Constraints
            NSLayoutConstraint.activate([
               //  location button constraints
                locationButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 10),
                locationButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -20),
                
                locationLabel.topAnchor.constraint(equalTo: locationButton.topAnchor),
                locationLabel.trailingAnchor.constraint(equalTo: locationButton.leadingAnchor, constant: -15),
                locationLabel.centerYAnchor.constraint(equalTo: locationButton.centerYAnchor),

                //MARK: buttonStack constraints
                buttonStack.topAnchor.constraint(lessThanOrEqualTo: locationButton.bottomAnchor, constant: 70),
                buttonStack.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
                buttonStack.heightAnchor.constraint(equalToConstant: 50),
                buttonStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                // MARK: current location label constraints
                currentUsersLocationLabel.bottomAnchor.constraint(equalTo: sunTableView.topAnchor, constant: 20),
                currentUsersLocationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                
            //MARK: SunTable Constraints
                sunTableView.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 30),
                sunTableView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.8),
                sunTableView.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor, multiplier: 0.3),
                sunTableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                
                
                // MARK: Day Length View constraints
                
                dayLengthTitle.topAnchor.constraint(equalTo: dayLengthView.topAnchor),
                dayLengthTitle.leadingAnchor.constraint(equalTo: dayLengthView.leadingAnchor),
                
                dayLengthLabel.bottomAnchor.constraint(equalTo: dayLengthView.bottomAnchor),
                dayLengthLabel.centerXAnchor.constraint(equalTo: dayLengthView.centerXAnchor),
                
                dayLengthView.topAnchor.constraint(equalTo: sunTableView.bottomAnchor, constant: 30),
                dayLengthView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                dayLengthView.heightAnchor.constraint(equalTo: view.layoutMarginsGuide.heightAnchor, multiplier: 0.1),
                dayLengthView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6)
            ])
        }
}

