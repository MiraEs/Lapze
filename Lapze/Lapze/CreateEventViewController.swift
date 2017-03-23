//
//  CreateEventViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/3/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import Social
import UserNotifications

public enum Activity: String {
    case running = "Running"
    case cycling = "Cycling"
    case skateBoarding = "Skate Boarding"
    case rollerSkating = "Roller Skating"
    case basketBall = "Basketball"
    case soccer = "Soccer"
}

enum DatePickerType {
    case date
    case startTime
    case endTime
}

protocol EventViewControllerDelegate{
    func startEvent(name: String, showUserLocation: Bool)
}

class CreateEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let activities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating, .basketBall, .soccer]
    let noTimeLimitActivities: [Activity] = [.running, .cycling, .skateBoarding, .rollerSkating]
    var currentPickerType: DatePickerType = .date
    var pickedActivity: Activity =  .running
    var delegate: EventViewControllerDelegate?
    var shareLocation = false
    var shareProfile = false
    private var userEventInfo: [String:String] = ["type":"","date":"","start":"","end":""]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Event"
        self.view.backgroundColor = ColorPalette.spaceGrayColor
        
        setupViewHierarchy()
        configureConstraints()
    }

    //MARK: - Utilities    
    func locationSwitchValueChanged(sender: UISwitch) {
        print("Before status: \(shareLocation)")
        shareLocation = !shareLocation
        
        switch shareLocation{
        case true:
            infoView.titleLabel.text = "Your location is now public"
        case false:
            infoView.titleLabel.text = "Your location is now private"
        }
        
        animateInfoView()
        print("Now status: \(shareLocation)")
    }
    
    func privacySwitchValueChanged(sender: UISwitch) {
        shareProfile = !shareProfile
        //test - facebook post
        switch shareProfile {
        case true:
            infoView.titleLabel.text = "Sharing to Facebook!"
        case false:
            infoView.titleLabel.text = "Not sharing to Facebook!"
            break
        }
        
        animateInfoView()
    }
    
    func shareEventOnFb() {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook){
            let facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            facebookSheet.setInitialText("Join my \(self.pickedActivity) event on LAPZE!")
            facebookSheet.completionHandler = {(result:SLComposeViewControllerResult) -> Void in
                switch result {
                case SLComposeViewControllerResult.done:
                    self.notificationEvent()
                case SLComposeViewControllerResult.cancelled:
                    break
                }
            }
            self.present(facebookSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil )
        }
    }
    
    
    func notificationEvent() {
        let content = UNMutableNotificationContent()
        content.title = "Posted Event!"
        content.body = "You shared your \(pickedActivity) event onto Facebook! Yay!"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "event", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func cancelButtonTapped(sender: UIBarButtonItem) {
        print("cancel tapped")
        dismissViewcontroller()
    }
    
    func doneButtonTapped(sender: UIBarButtonItem) {
        print("done tapped")
        
        let alertController = showAlert(title: "Start this event?", message: "Tap ok to start the event!", useDefaultAction: false)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            //test - facebook post
            if self.shareProfile {
                self.shareEventOnFb()
            }
            self.dismissViewcontroller()
            self.addEventToFirebase()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    func dismissViewcontroller(){
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    private func createEventObject() -> Event{
        
        let userId = FIRAuth.auth()?.currentUser?.uid
        let currentLocation = LocationManager.sharedManager.currentLocation
        let event = Event(id: userId! , type: pickedActivity.rawValue, date: "", location: Location(location: currentLocation!))
        return event
    }
    
    private func addEventToFirebase(){
        let eventObj = self.createEventObject()
        FirebaseManager.shared.addToFirebase(event: eventObj)
        self.delegate?.startEvent(name: eventObj.type, showUserLocation: shareLocation)
    }
    
    func showDatePicker() {
        for view in pickerContainer.subviews {
            view.removeFromSuperview()
        }
        self.pickerContainer.addSubview(datePicker)
        datePicker.snp.makeConstraints { (view) in
            view.top.bottom.left.right.equalToSuperview()
        }
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
    
    func dateLabelTapped(sender:UITapGestureRecognizer) {
        currentPickerType = .date
        datePicker.datePickerMode = .date
        showDatePicker()
    }
    
    func startTimeLabelTapped(sender:UITapGestureRecognizer) {
        currentPickerType = .startTime
        datePicker.datePickerMode = .time
        showDatePicker()
    }
    
    func endTimeLabelTapped(sender:UITapGestureRecognizer) {
        currentPickerType = .endTime
        datePicker.datePickerMode = .time
        showDatePicker()
    }
    
    func datePicked(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        switch currentPickerType {
        case DatePickerType.date:
            datePicker.datePickerMode = UIDatePickerMode.date
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pickedDateLabel.text = dateFormatter.string(from: datePicker.date)
            userEventInfo["date"] = dateFormatter.string(from: datePicker.date)
        case DatePickerType.startTime:
            datePicker.datePickerMode = UIDatePickerMode.time
            dateFormatter.dateFormat = "hh:mm a"
            pickedStartTimeLabel.text = dateFormatter.string(from: datePicker.date)
            userEventInfo["start"] = dateFormatter.string(from: datePicker.date)
        case DatePickerType.endTime:
            datePicker.datePickerMode = UIDatePickerMode.time
            dateFormatter.dateFormat = "hh:mm a"
            pickedEndTimeLabel.text = dateFormatter.string(from: datePicker.date)
            userEventInfo["end"] = dateFormatter.string(from: datePicker.date)
        }
    }
    
    private func getEventInfo(){
        print(userEventInfo)
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
        
        pickedActivity = activities[row]
        pickedActivityLabel.text = pickedActivity.rawValue
        userEventInfo["type"] = pickedActivity.rawValue
     
    }
    
    private func animateInfoView(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 2, curve: .easeIn)
        
        animator.addAnimations {
            self.infoView.transform = CGAffineTransform(translationX: 0, y: -60)
        }
        
        animator.addAnimations({ 
            self.infoView.transform = CGAffineTransform.identity
        }, delayFactor: 0.8)
        
        animator.startAnimation()
    }
    //MARK: - Setup
    func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        self.view.addSubview(activityContainer)
        self.view.addSubview(dateContainer)
        self.view.addSubview(startTimeContainer)
        self.view.addSubview(endTimeContainer)
        self.view.addSubview(privacyLabel)
        self.view.addSubview(locationContainer)
        self.view.addSubview(privacyContainer)
        self.view.addSubview(pickerContainer)
        self.view.addSubview(infoView)
        self.activityContainer.addSubview(activityLabel)
        self.activityContainer.addSubview(pickedActivityLabel)
        self.dateContainer.addSubview(dateLabel)
        self.dateContainer.addSubview(pickedDateLabel)
        self.startTimeContainer.addSubview(startTimeLabel)
        self.startTimeContainer.addSubview(pickedStartTimeLabel)
        self.endTimeContainer.addSubview(endTimeLabel)
        self.endTimeContainer.addSubview(pickedEndTimeLabel)
        self.locationContainer.addSubview(locationLabel)
        self.locationContainer.addSubview(locationSwitch)
        self.privacyContainer.addSubview(sharingStatusLabel)
        self.privacyContainer.addSubview(privacySwitch)
    }
    
    func configureConstraints() {
        infoView.snp.makeConstraints { (view) in
            view.top.equalTo(self.view.snp.bottom)
            view.height.equalToSuperview().multipliedBy(0.08)
            view.leading.trailing.equalToSuperview()
        }
        activityContainer.snp.makeConstraints { (view) in
            view.top.equalToSuperview().offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        dateContainer.snp.makeConstraints { (view) in
            view.top.equalTo(activityContainer.snp.bottom).offset(22.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        startTimeContainer.snp.makeConstraints { (view) in
            view.top.equalTo(dateContainer.snp.bottom).offset(1.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        endTimeContainer.snp.makeConstraints { (view) in
            view.top.equalTo(startTimeContainer.snp.bottom).offset(1.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        privacyLabel.snp.makeConstraints { (view) in
            view.top.equalTo(endTimeContainer.snp.bottom).offset(22.0)
            view.left.equalToSuperview().offset(16.0)
            view.height.equalTo(26.0)
        }
        locationContainer.snp.makeConstraints { (view) in
            view.top.equalTo(privacyLabel.snp.bottom)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
        }
        privacyContainer.snp.makeConstraints { (view) in
            view.top.equalTo(locationContainer.snp.bottom).offset(1.0)
            view.left.right.equalToSuperview()
            view.height.equalTo(44.0)
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
        dateLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedDateLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        startTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedStartTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        endTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        pickedEndTimeLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
            view.width.equalTo(150.0)
        }
        locationLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(100.0)
        }
        locationSwitch.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
        }
        sharingStatusLabel.snp.makeConstraints { (view) in
            view.top.bottom.equalToSuperview()
            view.left.equalToSuperview().offset(16.0)
            view.width.equalTo(200.0)
        }
        privacySwitch.snp.makeConstraints { (view) in
            view.centerY.equalToSuperview()
            view.right.equalToSuperview().inset(16.0)
        }
        pickerContainer.snp.makeConstraints { (view) in
            view.top.equalTo(privacyContainer.snp.bottom).offset(16.0)
            view.bottom.left.right.equalToSuperview()
        }
    }
    
    //MARK: - Views
    // Acitivity, Date, Start Time, End, Location, Public
    
    internal lazy var activityContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var dateContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var startTimeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var endTimeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var locationContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var privacyContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var pickerContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    internal lazy var activityLabel: UILabel = {
        let label = UILabel()
        label.text = "Activity"
        return label
    }()
    internal lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        return label
    }()
    internal lazy var startTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        return label
    }()
    internal lazy var endTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "End"
        return label
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
    
    internal lazy var pickedDateLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dateLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var pickedStartTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(startTimeLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var pickedEndTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "..."
        label.textColor = .lightGray
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(endTimeLabelTapped(sender:)))
        label.addGestureRecognizer(tap)
        return label
    }()
    internal lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.text = "PRIVACY"
        label.textColor = .gray
        label.font = label.font.withSize(14)
        label.textAlignment = .left
        return label
    }()
    internal lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Location"
        return label
    }()
    internal lazy var sharingStatusLabel: UILabel = {
        let label = UILabel()
        label.text = "Share On Facebook"
        return label
    }()
    internal lazy var locationSwitch: UISwitch = {
        let theSwitch = UISwitch()
        theSwitch.addTarget(self, action: #selector(locationSwitchValueChanged(sender:)), for: .valueChanged)
        return theSwitch
    }()
    internal lazy var privacySwitch: UISwitch = {
        let theSwitch = UISwitch()
        theSwitch.addTarget(self, action: #selector(privacySwitchValueChanged(sender:)), for: .valueChanged)
        return theSwitch
    }()
    internal lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: #selector(datePicked(sender:)), for: .valueChanged)
        return datePicker
    }()
    internal lazy var activityPickerView: UIPickerView! = {
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
    
    private let infoView: TopActivityInfoView = {
        let infoView = TopActivityInfoView()
        infoView.backgroundColor = .red
        return infoView
    }()
    
}
