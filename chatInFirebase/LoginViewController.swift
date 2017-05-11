//
//  LoginViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 12/29/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

import FBSDKLoginKit


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {

    var messagesViewController: MessagesViewController? // for access its func; 

    let isIphone5 : Bool = (UIScreen.main.bounds.height < 600)
    let topMargin : CGFloat = (UIScreen.main.bounds.height < 600) ? 10 : 20

    let acceptedEULAKey = "UserAcceptedEULAContent"

    lazy var profileImageView : UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = #imageLiteral(resourceName: "guaiqiao01")
        img.contentMode = .scaleAspectFit
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        // needs lazy var for this self:
        img.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectingImageView)))
        img.isUserInteractionEnabled = true
        return img
    }()
    
    let inputsContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false // for Anchor
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true
        return view
    }()
    
    let nameTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Nick name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocorrectionType = .no
        return tf
    }()
    
    func addLineSeprator() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor(r: 200, g: 200, b: 200)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }
    
    let emailTextField : UITextField = {
        let ef = UITextField()
        ef.placeholder = "Email"
        ef.translatesAutoresizingMaskIntoConstraints = false
        ef.keyboardType = .emailAddress
        ef.autocorrectionType = .no
        return ef
    }()
    
    let passwordTextField: UITextField = {
        let p = UITextField()
        p.placeholder = "Password"
        p.translatesAutoresizingMaskIntoConstraints = false
        p.isSecureTextEntry = true
        return p
    }()
    
    let passwordConfernTextField: UITextField = {
        let p = UITextField()
        p.placeholder = "Type password again"
        p.translatesAutoresizingMaskIntoConstraints = false
        p.isSecureTextEntry = true
        return p
    }()

    var nameSepratorLine : UIView!
    var emailSepratorLine: UIView!
    var passWordSepratorLine:UIView!
    
    lazy var loginRegisterButton : UIButton = { // lazy is for access self
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false // for Anchor
        b.setTitle("Register", for: .normal)
        b.setTitleColor(UIColor.white, for: .normal)
        b.titleLabel?.font = UIFont(name: "Verdana", size: 26)
        b.backgroundColor = buttonColorPurple
        b.layer.cornerRadius = 7
        // needs lazy var for this self:
        b.addTarget(self, action: #selector(loginOrRegister), for: .touchUpInside) // in extension file;
        return b
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Login", "Register"])
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.tintColor = UIColor.white
        seg.selectedSegmentIndex = 1
        seg.addTarget(self, action: #selector(loginRegisterModeChanged), for: .valueChanged)
        return seg
    }()

    lazy var fbLoginButton : FBSDKLoginButton = {
        let b = FBSDKLoginButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.delegate = self
        b.readPermissions = ["email", "public_profile"]
        return b
    }()
    
    //=== setup UI ============================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(r: 68, g: 36, b: 133) // 61,91,151
        setupBackgroundGradientLayer()
    
        self.view.addSubview(loginRegisterSegmentedControl)
        self.view.addSubview(profileImageView)
        self.view.addSubview(inputsContainerView)
        self.view.addSubview(loginRegisterButton)
        self.view.addSubview(fbLoginButton)
        setupProfileImageView()
        setupLoginSegmentControl()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupFbLoginButton()
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUserAgreementContentAlert()
    }
    
    private func setupProfileImageView(){
        let topConstant : CGFloat = isIphone5 ? 30 : 60
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -26).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: topConstant).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    private func setupLoginSegmentControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo:inputsContainerView.widthAnchor, multiplier: 2/3).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginRegisterSegmentedControl.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: topMargin).isActive = true
    }
    func loginRegisterModeChanged(){
        let mode = loginRegisterSegmentedControl.selectedSegmentIndex // 0=login, 1=register
        let inputsCVHeightAnc = inputsContainerView.heightAnchor
        
        // change title of login button:
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        loginRegisterButton.backgroundColor = (mode == 0) ? buttonColorBlue : buttonColorPurple
        
        inputContainerViewHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 80 : 160

        // chnage nameTextField showing:
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 0 : 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = (loginRegisterSegmentedControl.selectedSegmentIndex == 0) // must need this !!!
 
        // change emailTextField showing:
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 1/2 : 1/4)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change passwordTextField showing:
        passwTextFieldHeightAnchor?.isActive = false
        passwTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 1/2 : 1/4)
        passwTextFieldHeightAnchor?.isActive = true
        
        // change passwordConfernTextField showing:
        passw2TextFieldHeightAnchor?.isActive = false
        passw2TextFieldHeightAnchor = passwordConfernTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 0 : 1/4)
        passw2TextFieldHeightAnchor?.isActive = true
        passwordConfernTextField.isHidden = (mode == 0)
    }

    private func setupBackgroundGradientLayer(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.frame
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.5, 1.2]
        self.view.layer.addSublayer(gradientLayer)
    }
    
    
    var inputContainerViewHeightConstraint : NSLayoutConstraint?
    var nameTextFieldHeightAnchor :          NSLayoutConstraint?
    var emailTextFieldHeightAnchor:          NSLayoutConstraint?
    var passwTextFieldHeightAnchor:          NSLayoutConstraint?
    var passw2TextFieldHeightAnchor:         NSLayoutConstraint?
    
    func setupInputsContainerView(){
        // set up x, y, width, hight:
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.topAnchor.constraint(equalTo: loginRegisterSegmentedControl.bottomAnchor, constant: topMargin).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        // inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        inputContainerViewHeightConstraint = inputsContainerView.heightAnchor.constraint(equalToConstant: 160)
        inputContainerViewHeightConstraint?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 30).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        nameTextFieldHeightAnchor?.isActive = true
        
        nameSepratorLine = addLineSeprator() // -----------------------------
        inputsContainerView.addSubview(nameSepratorLine)
        nameSepratorLine.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSepratorLine.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSepratorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSepratorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: nameSepratorLine.topAnchor).isActive = true
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 30).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        // emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        emailTextFieldHeightAnchor?.isActive = true

        emailSepratorLine = addLineSeprator() // -----------------------------
        inputsContainerView.addSubview(emailSepratorLine)
        emailSepratorLine.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSepratorLine.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSepratorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSepratorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(passwordTextField)
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 30).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        // passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3).isActive = true
        passwTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        passwTextFieldHeightAnchor?.isActive = true
        
        passWordSepratorLine = addLineSeprator() // -----------------------------
        inputsContainerView.addSubview(passWordSepratorLine)
        passWordSepratorLine.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passWordSepratorLine.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passWordSepratorLine.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passWordSepratorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        inputsContainerView.addSubview(passwordConfernTextField)
        passwordConfernTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordConfernTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 30).isActive = true
        passwordConfernTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passw2TextFieldHeightAnchor = passwordConfernTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/4)
        passw2TextFieldHeightAnchor?.isActive = true
    }

    func setupLoginRegisterButton(){
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: topMargin).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupFbLoginButton(){
        fbLoginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        fbLoginButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        fbLoginButton.widthAnchor.constraint(equalTo: loginRegisterButton.widthAnchor).isActive = true
        fbLoginButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func setupUserAgreementContentAlert(){
        let userAgreedContent = UserDefaults.standard.object(forKey: acceptedEULAKey) as? Bool
        if userAgreedContent == nil || userAgreedContent == false {
            fbLoginButton.isHidden = true
            showUserContentAlert()
        }else{
            fbLoginButton.isHidden = false
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}

