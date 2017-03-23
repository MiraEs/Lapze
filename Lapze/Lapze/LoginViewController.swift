//
//  LoginViewController.swift
//  Lapze
//
//  Created by Madushani Lekam Wasam Liyanage on 3/6/17.
//  Copyright © 2017 Lapze Inc. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    private enum LoginBehavior{
        case register,login
    }
    private var viewControllerState: LoginBehavior = .login
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = ColorPalette.logoGreenColor
        setupViewHierarchy()
        configureConstraints()
        
        observeKeyboardNotifications()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        logoAnimation()
        
    }
    
    func loginTapped() {
        switch viewControllerState{
        case .login:
            logInUser()
        case .register:
            registerUser()
        }
    }
    
    func gotoRegisterTapped(sender: UIButton) {
        print("signup")
        
        let registerVC = RegisterViewController()
        self.navigationController?.pushViewController(registerVC, animated:true)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: .UIKeyboardDidHide, object: nil)
    }
    
    //MARK:- Keyboard
    @objc private func showKeyboard(notification : NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
        
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
            UIView.animate(withDuration: 0.5) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: 50)
            }
        }
    }
    
    @objc private func hideKeyboard(notification: NSNotification) {
        
        UIView.animate(withDuration: 0.2) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
    }
    
    @objc private func updateViewController(){
        switch viewControllerState{
        case .login:
            self.actionButton.setTitle("Register", for: .normal)
            self.gotoRegisterButton.setTitle("Already have an account?", for: .normal)
            animateUserNameTextfieldIn()
            viewControllerState = .register
        case .register:
            self.actionButton.setTitle("Login", for: .normal)
            self.gotoRegisterButton.setTitle("Don't have an account?", for: .normal)
            animateUserNameTextfieldOut()
            viewControllerState = .login
        }
    }
    
    //MARK:- User signin utilities
    private func registerUser(){
        if let email = emailTextField.text, let password = passwordTextField.text, let username = userNameTextField.text {
            
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Creating Error \(error.localizedDescription)")
                    let alertController = showAlert(title: "Registering Failed!", message: "Failed to Register. Please Try Again!", useDefaultAction: true)
                    self.present(alertController, animated: true, completion: nil)
                    
                }
                else {
                    let alertController = showAlert(title: "Signup Successful!", message: "Successfully Registered. You will be automatically logged in!", useDefaultAction: false)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                        let userDict = ["name": username, "challengeCount": 0, "eventCount": 0] as [String:Any]
                        FirebaseManager.shared.updateFirebase(closure: { (ref) in
                            ref.child((FIRAuth.auth()?.currentUser?.uid)!).setValue(userDict)
                        })
                        self.clearTextFields()
                        let tabVC = EventsViewController()
                        //                        self.navigationController?.pushViewController(tabVC, animated:true)
                        //                        FIRAuth.auth().
                        
                    }))
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
        }
    }
    
    private func logInUser(){
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("User Login Error \(error.localizedDescription)")
                    let alertController = showAlert(title: "Login Failed!", message: "Failed to Login. Please Check Your Email and Password!", useDefaultAction: true)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                else {
                    let alertController = showAlert(title: "Login Successful!", message: nil, useDefaultAction: false)
                    
                    alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                        self.dismiss(animated: true, completion: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
    }
    
    private func animateUserNameTextfieldIn(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeIn)
        
        self.userNameTextField.snp.remakeConstraints { (view) in
            view.top.equalTo(self.passwordTextField.snp.bottom).offset(16.0)
            view.centerX.equalToSuperview()
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        
        self.actionButton.snp.remakeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(self.userNameTextField.snp.bottom).offset(16.0)
            view.width.equalTo(100.0)
            view.height.equalTo(30.0)
        }
        
        animator.addAnimations {
            self.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    private func animateUserNameTextfieldOut(){
        let animator: UIViewPropertyAnimator = UIViewPropertyAnimator(duration: 1, curve: .easeIn)
        self.userNameTextField.snp.remakeConstraints { (view) in
            view.leading.equalTo(self.view.snp.trailing)
            view.centerY.equalToSuperview()
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        
        self.actionButton.snp.remakeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(self.passwordTextField.snp.bottom).offset(16.0)
            view.width.equalTo(100.0)
            view.height.equalTo(30.0)
        }
        
        animator.addAnimations {
            self.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        loginTapped()
        self.view.endEditing(true)
        return false
    }
    
    func logoAnimation() {
        UIView.animate(withDuration: 1, animations: {
            self.logoOuterRing.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        }, completion: { (_) in
            self.logoAnimation()
        })
    }
    
    //MARK: - Setup
    private func setupViewHierarchy() {
        self.edgesForExtendedLayout = []
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(container)
        self.container.addSubview(logoImageView)
        self.container.addSubview(emailTextField)
        self.container.addSubview(userNameTextField)
        self.container.addSubview(passwordTextField)
        self.container.addSubview(actionButton)
        self.container.addSubview(gotoRegisterButton)
        self.container.addSubview(logoImageView)
        self.container.addSubview(logoInnerRing)
        self.container.addSubview(logoMiddleRing)
        self.container.addSubview(logoOuterRing)
    }
    
    private func configureConstraints() {
        
        scrollView.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
        }
        
        container.snp.makeConstraints { (view) in
            view.leading.trailing.top.bottom.equalToSuperview()
            view.height.equalTo(self.view.snp.height)
            view.width.equalTo(self.view.snp.width)
        }
        
        userNameTextField.snp.makeConstraints { (view) in
            view.leading.equalTo(self.view.snp.trailing)
            view.centerY.equalToSuperview()
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        
        logoOuterRing.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalToSuperview().offset(20.0)
        }
        
        logoMiddleRing.snp.makeConstraints { (view) in
            view.leading.equalTo(logoOuterRing)
            view.centerY.equalTo(logoOuterRing)
        }
        
        logoInnerRing.snp.makeConstraints { (view) in
            view.centerY.equalTo(logoOuterRing)
            view.leading.equalTo(logoOuterRing)
        }
        logoImageView.snp.makeConstraints { (view) in
            view.centerX.equalTo(logoInnerRing)
            view.centerY.equalTo(logoInnerRing)
        }
        
        //test^^
        emailTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(logoOuterRing.snp.bottom).offset(25.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
        }
        passwordTextField.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(emailTextField.snp.bottom).offset(16.0)
            view.width.equalTo(225.0)
            view.height.equalTo(30.0)
            
        }
        actionButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(passwordTextField.snp.bottom).offset(16.0)
            view.width.equalTo(100.0)
            view.height.equalTo(30.0)
        }
        gotoRegisterButton.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.top.equalTo(actionButton.snp.bottom).offset(8.0)
            //view.width.equalTo(200.0)
            view.height.equalTo(30.0)
        }
    }
    
    func clearTextFields() {
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        return scrollView
    }()
    private let container: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = ColorPalette.logoGreenColor
        return view
    }()
    
    //MARK: - View init
    internal lazy var logoOuterRing: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "outerRingw")
        return imageView
    }()
    
    internal lazy var logoMiddleRing: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "middleRingw")
        return imageView
    }()
    
    internal lazy var logoInnerRing: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "innerRingw")
        return imageView
    }()
    
    //test^^
    internal lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logoTitlew")
        return imageView
    }()
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.keyboardType = .emailAddress
        return textField
    }()
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        return textField
    }()
    private lazy var userNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Username"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        return textField
    }()
    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ColorPalette.orangeThemeColor
        button.layer.cornerRadius = 8.0
        button.layer.masksToBounds = false
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    private lazy var gotoRegisterButton: UIButton = {
        let button = UIButton()
        button.setTitle("Don't have an account?", for: .normal)
        button.addTarget(self, action: #selector(updateViewController), for: .touchUpInside)
        return button
    }()
}
