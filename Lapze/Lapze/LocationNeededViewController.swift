//
//  LocationNeedViewController.swift
//  Lapze
//
//  Created by Jermaine Kelly on 3/16/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import CoreLocation

class LocationNeededViewController: UIViewController {
    private let locMan = LocationManager.sharedManager
    var onLocationPermissionsGranted: (() -> Void)?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = ColorPalette.logoGreenColor
        setUpViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(locationStatusDidUpdate(notification:)),
                                               name: NSNotification.Name(LocationManager.locationStatusDidChange),
                                               object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    override func viewDidAppear(_ animated: Bool) {
        LocationManager.sharedManager.requestWhenInUse()
    }
    private func setUpViewController(){
        view.addSubview(infoLabel)
        infoLabel.isHidden = true
        infoLabel.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.trailing.equalToSuperview().inset(20)
            view.leading.equalToSuperview().offset(20)
        }
    }
    
    @objc private func locationStatusDidUpdate(notification: NSNotification) {
        guard let status = notification.object as? CLAuthorizationStatus
            else { fatalError("Developer error. expected object type: CLAuthorizationStatus") }
        
        switch status {
        case .authorizedWhenInUse:
            dismiss(animated: true) {
                self.onLocationPermissionsGranted?()
            }
        // remove this vc from tab bar and set up normal flow
        default: // pop alert controller saying to use Lapze location permission is needed. You can change these permissions in your device's settings. Settings > Lapze > Location > Check 'When In Use'
            infoLabel.isHidden = false
            //showAlert()
        }
    }
    
    private func checkForAuth(){
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse{
            showAlert()
        }
    }
    
    private func showAlert(){
        let alert: UIAlertController = UIAlertController(title: "Lapze location Permission Needed", message: nil, preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private let infoLabel: UILabel = {
        let label: UILabel = UILabel()
        label.text = "You can change these permissions in your device's settings.\nSettings > Lapze > Location > Check 'When In Use'"
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
    return label
    }()
    
}
