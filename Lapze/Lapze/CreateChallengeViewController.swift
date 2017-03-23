//
//  CreateChallengeViewController.swift
//  Lapze
//
//  Created by Ilmira Estil on 3/7/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

protocol ChallengeDelegate {
    func challengeCreated(_ challenge: Challenge)
}

class CreateChallengeViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate {
    
    let activities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating, .basketBall, .soccer]
    var shareLocation = false
    var shareProfile = false
    var delegate: ChallengeDelegate?
    
    var challengeRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Challenge"
        self.view.backgroundColor = ColorPalette.spaceGrayColor
        
        setupViewHierarchy()
        configureConstraints()
        challengeNameTextField.delegate = self
    }
    
    //MARK: - Utilities
    func locationSwitchValueChanged(sender: UISwitch) {
        print("Before status: \(shareLocation)")
        shareLocation = !shareLocation
        print("Now status: \(shareLocation)")
    }
    
    func privacySwitchValueChanged(sender: UISwitch) {
        shareProfile = !shareProfile
    }
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        print("cancel tapped")
        _ = navigationController?.popViewController(animated: true)
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        
        guard pickedActivityLabel.text != "..." && challengeNameTextField.text != nil else {
            let alertController = showAlert(title: "Unsuccessful!", message: "Challenge name and type can't be blank.", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if isLocationOn() {
            
            let alertController = showAlert(title: "Create this challenge?", message: nil, useDefaultAction: false)
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                self.dismissViewcontroller()
                self.createChallenge()
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
            
        else {
            let alertController = showAlert(title: "Unsuccessful", message: "Seems like your location is not turned on, please check your settings!", useDefaultAction: true)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func createChallenge() {
        
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let date = getCurrentDateString()
        let newChallenge = Challenge(name: challengeNameTextField.text!,
                                     champion: userId,
                                     lastUpdated: date,
                                     type: pickedActivityLabel.text!)
        self.delegate?.challengeCreated(newChallenge)
    }
    
    func isLocationOn() -> Bool {
        let locationManager = CLLocationManager()
        if locationManager.location != nil {
            return true
        }
        return false
    }
    
    func dismissViewcontroller(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func showActivityPicker() {
        for view in pickerContainer.subviews {
            view.removeFromSuperview()
        }
        self.pickerContainer.addSubview(activityPickerView)
        activityPickerView.delegate = self
        activityPickerView.dataSource = self
        activityPickerView.snp.makeConstraints { (view) in
            view.top.bottom.left.right.equalToSuperview()
        }
    }
    
    func activityLabelTapped(sender:UITapGestureRecognizer) {
        showActivityPicker()
    }
    
    //MARK: - Delegates and data sources
    
    //MARK: Data Sources
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activities.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activities[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let pickedActivity = activities[row]
        pickedActivityLabel.text = pickedActivity.rawValue
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - Setup
    
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        self.view.addSubview(challengeNameContainer)
        self.view.addSubview(activityContainer)
        self.view.addSubview(pickerContainer)
        self.challengeNameContainer.addSubview(challengeNameLabel)
        self.challengeNameContainer.addSubview(challengeNameTextField)
        self.activityContainer.addSubview(activityLabel)
        self.activityContainer.addSubview(pickedActivityLabel)
    }
    
    func configureConstraints() {
        challengeNameContainer.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        activityContainer.snp.makeConstraints { (view) in
            view.top.equalTo(challengeNameContainer.snp.bottom).offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        challengeNameLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(135.0)
        }
        challengeNameTextField.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(175.0)
        }
        activityLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedActivityLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        pickerContainer.snp.makeConstraints { (view) in
            view.bottom.left.right.equalToSuperview()
        }
    }
    
    //MARK: - Views
    // Acitivity, Name
    
    internal lazy var challengeNameContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var activityContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var pickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var challengeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Challenge Name"
        return label
    }()
    internal lazy var activityLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        return label
    }()
    internal lazy var challengeNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a description"
        textField.textAlignment = .right
        return textField
    }()
    internal lazy var pickedActivityLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(activityLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var activityPickerView: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    internal lazy var doneButton: UIBarButtonItem = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped(sender:)))
        return barButton
    }()
    internal lazy var cancelButton: UIBarButtonItem = {
        var barButton = UIBarButtonItem()
        barButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelButtonTapped(sender:)))
        return barButton
    }()
}
