//
//  ViewController.swift
//  sunRiseSet
//
//  Created by David Chester on 1/29/22.
//

import UIKit
import CoreLocation

class MainViewController: UIViewController {
    let locationManager = CLLocationManager()
    
    var sunModels = [SunModel]()
    var moonModels = [MoonModel]()

    var cellModel: CellModel!
    var sunTimesManager = SunTimesManager()

    let mainView = MainView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // delegates and datasource
        mainView.sunTableView.delegate = self
        mainView.sunTableView.dataSource = self
        sunTimesManager.delegate = self
       
        //location manager delegate and auth request
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        // registering custom cell
        mainView.sunTableView.register(SunCell.self, forCellReuseIdentifier: SunCell.identifier)
    }
    // MARK: pressed button
    @objc func userPressedLocationButton()  {
        sunModels.removeAll()
        moonModels.removeAll()
        mainView.sunTableView.reloadData()
        mainView.locationLabel.isHidden = true
        mainView.dateButtons[0].isSelected = true
        mainView.dateButtons[1].isSelected = false

        if locationManager.authorizationStatus == .authorizedWhenInUse  {
            locationManager.startUpdatingLocation()
        } else if locationManager.authorizationStatus == .denied {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}



// MARK: suntimes Manager delegate
extension MainViewController: SunTimesManagerDelegate {
    func didUpdateTimes(sunTimesManager: SunTimesManager, sunTimesCellModel: CellModel) {
        
        DispatchQueue.main.async {
            self.mainView.buttonStack.isHidden = false
            self.mainView.dayLengthView.isHidden = false
            self.sunModels.append(contentsOf: sunTimesCellModel.sun)
            self.moonModels.append(contentsOf: sunTimesCellModel.moon)
            self.mainView.dayLengthLabel.text = sunTimesCellModel.dayLength
            self.mainView.sunTableView.reloadData()
        }
    }

    
    func didFailWithError(error: SunTimesError) {
        let alert = UIAlertController(title: "An error has occured", message: error.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true)
    }
}


// MARK: TableView DataSource & delegate
extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return mainView.sunTableView.frame.height / 20
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

        // depending on which button is selected we switch the model being sent to the cell
        if mainView.dateButtons[0].isSelected == true {
            let currentSunInfo = sunModels[indexPath.section]
            cell.sunInfo = currentSunInfo
        } else if mainView.dateButtons[1].isSelected == true {
            let currentSunInfo = moonModels[indexPath.section]
            cell.moonInfo = currentSunInfo
        }

        cell.backgroundColor = .clear
        let bgView = UIView()
        bgView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        bgView.layer.opacity = 0.2
        cell.selectedBackgroundView = bgView
        
        return cell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return mainView.sunTableView.frame.height / 3
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if mainView.dateButtons[0].isSelected == true {
            if indexPath.section == 0 {
                mainView.backgroundColor = UIColor(patternImage: UIImage(named: "peaches.png", in: Bundle.main, with: nil)!)
            } else {
                mainView.backgroundColor = UIColor(patternImage: UIImage(named: "sunset.png", in: Bundle.main, with: nil)!)
            }
        } else if mainView.dateButtons[1].isSelected == true {
            if indexPath.section == 0 {
                mainView.backgroundColor = UIColor(patternImage: UIImage(named: "dream.png", in: Bundle.main, with: nil)!)
            } else {
                mainView.backgroundColor = UIColor(patternImage: UIImage(named: "cotton candy.png", in: Bundle.main, with: nil)!)
            }
        }
    }
}

// MARK: Location Manager Methods
extension MainViewController: CLLocationManagerDelegate {

     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let userLocation = locations.first else { print("no location returned"); return }
        print(userLocation.coordinate)

        let lat = userLocation.coordinate.latitude
        let long = userLocation.coordinate.longitude

         showLocation(lat: lat, long: long)

         sunTimesManager.sunTimesURLGenerator(lat: lat, long: long)
         locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert =  UIAlertController(title: "An error has occured", message: "Could not get location", preferredStyle: .alert)
        
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
            print(placemarks)
            
            let city = placemarks.locality ?? ""
            let state = placemarks.administrativeArea ?? ""

            DispatchQueue.main.async {

                if city == "" {
                    self.mainView.currentUsersLocationLabel.text = "\(state)"
                } else  {
                    self.mainView.currentUsersLocationLabel.text = "\(city), \(state)"
                }
            }
        }
    }
}

// MARK: LoadView + button creation Extension
extension MainViewController {

        override func loadView() {
            view = UIView()

            view.addSubview(mainView)
            mainView.dateButtons[0].isSelected = true
            mainView.locationButton.addTarget(self, action: #selector(userPressedLocationButton), for: .touchUpInside)
            
            // MARK: Constraints
            NSLayoutConstraint.activate([
                mainView.topAnchor.constraint(equalTo: view.topAnchor),
                mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
}

