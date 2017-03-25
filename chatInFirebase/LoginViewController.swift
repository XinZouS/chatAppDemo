//
//  LoginViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 12/29/16.
//  Copyright © 2016 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    var messagesViewController: MessagesViewController? // for access its func; 

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
        return ef
    }()
    
    let passwordTextField: UITextField = {
        let pf = UITextField()
        pf.placeholder = "Password"
        pf.translatesAutoresizingMaskIntoConstraints = false
        pf.isSecureTextEntry = true
        return pf
    }()

    var nameSepratorLine : UIView!
    var emailSepratorLine: UIView!
    
    lazy var loginRegisterButton : UIButton = { // lazy is for access self
        let btn = UIButton(type: .system)
        btn.translatesAutoresizingMaskIntoConstraints = false // for Anchor
        btn.setTitle("Register", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Verdana", size: 26)
        btn.backgroundColor = UIColor(r: 160, g: 90, b: 253)
        btn.layer.cornerRadius = 7
        // needs lazy var for this self:
        btn.addTarget(self, action: #selector(loginOrRegister), for: .touchUpInside) // in extension file;
        
        return btn
    }()
    
    let loginRegisterSegmentedControl: UISegmentedControl = {
        let seg = UISegmentedControl(items: ["Login", "Register"])
        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.tintColor = UIColor.white
        seg.selectedSegmentIndex = 0
        seg.addTarget(self, action: #selector(loginRegisterModeChanged), for: .valueChanged)
        return seg
    }()

    
    //=== setup UI ============================================================
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
    
        self.view.addSubview(loginRegisterSegmentedControl)
        self.view.addSubview(profileImageView)
        self.view.addSubview(inputsContainerView)
        self.view.addSubview(loginRegisterButton)
        setupLoginSegmentControl()
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
    
    }
    
    func setupLoginSegmentControl(){
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo:inputsContainerView.widthAnchor, multiplier: 2/3).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
    }
    func loginRegisterModeChanged(){
        let mode = loginRegisterSegmentedControl.selectedSegmentIndex // 0=login, 1=register
        let inputsCVHeightAnc = inputsContainerView.heightAnchor
        
        // change title of login button:
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        inputContainerViewHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150

        // chnage nameTextField showing:
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 0 : 1/3)
        nameTextFieldHeightAnchor?.isActive = true
        nameTextField.isHidden = (loginRegisterSegmentedControl.selectedSegmentIndex == 0) // must need this !!!
 
        // change emailTextField showing:
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        // change passwordTextField showing; 
        passwTextFieldHeightAnchor?.isActive = false
        passwTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsCVHeightAnc, multiplier: mode == 0 ? 1/2 : 1/3)
        passwTextFieldHeightAnchor?.isActive = true
    }

    func setupProfileImageView(){
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -26).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
    }
    
    var inputContainerViewHeightConstraint : NSLayoutConstraint?
    var nameTextFieldHeightAnchor :          NSLayoutConstraint?
    var emailTextFieldHeightAnchor:          NSLayoutConstraint?
    var passwTextFieldHeightAnchor:          NSLayoutConstraint?
    
    func setupInputsContainerView(){
        // set up x, y, width, hight:
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30).isActive = true
        // inputsContainerView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        inputContainerViewHeightConstraint = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputContainerViewHeightConstraint?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 30).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
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
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
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
        passwTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwTextFieldHeightAnchor?.isActive = true
    }

    func setupLoginRegisterButton(){
        // set up x, y, width, hight:
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 20).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

}

extension UIColor {
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
