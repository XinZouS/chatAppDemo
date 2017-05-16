//
//  ProfileViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/7/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit


class ProfileViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                                FBSDKLoginButtonDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var msgViewController : MessagesViewController?
    var currUser: User?
    
    lazy var nameTextField : UITextField = {
        let l = UITextField()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.backgroundColor = UIColor(r: 246, g: 230, b: 255) // .clear
        l.delegate = self
        l.font = UIFont.systemFont(ofSize: 20)
        l.textAlignment = .center
        l.placeholder = "My Name here~~"
        return l
    }()
    
//    lazy var nameTextView: UITextView = { // not using this bcz textView only has ONE row;
//        let t = UITextView()
//        t.translatesAutoresizingMaskIntoConstraints = false
//        t.backgroundColor = UIColor(r: 246, g: 230, b: 255) // .clear
//        t.font = UIFont.systemFont(ofSize: 20)
//        t.textAlignment = .center
//        t.text = "My Name here~~"
//        return t
//    }()
    
    var imageDidChanged = false
    lazy var profileImageView : UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFit
        i.isUserInteractionEnabled = true
        i.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImg)))
        i.image = #imageLiteral(resourceName: "guaiqiao01")
        return i
    }()
    
    var signatureString = ""
    let textViewPlaceholder = " Hi~ what's new today?"
    lazy var signatureTextView : UITextView = {
        let v = UITextView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.delegate = self
        v.text = self.signatureString == "" ? " Hi~ what's new today?" : self.signatureString
        v.textColor = self.signatureString == "" ? .lightGray : .black
        v.font = UIFont.systemFont(ofSize: 16)
        v.layer.borderWidth = 1
        v.layer.borderColor = buttonColorPurple.cgColor
        return v
    }()
    
    var signatureTextViewTopconstraint : NSLayoutConstraint?
    var signatureTextViewTopconstraintOriginConst : CGFloat?
    
    lazy var saveButton : UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Save changes", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        b.backgroundColor = buttonColorBlue // buttonColorPurple
        b.addTarget(self, action: #selector(saveChangesToFirebase), for: .touchUpInside)
        return b
    }()
    
    lazy var logoutButton : UIButton = {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Log Out", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        b.backgroundColor = buttonColorRed
        b.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return b
    }()
    
    lazy var fbLoginButton : FBSDKLoginButton = {
        let b = FBSDKLoginButton()
        b.delegate = self
        b.readPermissions = ["email", "public_profile"]
        return b
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        
        setupViewContents()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUserAndView()
        
        setupKeyboardObservers()
        setupFbLoginButton()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    private func updateUserAndView(){
        if let getUser = msgViewController?.currUser {
            currUser = getUser
        }else{
            fetchUserFromFirebase()
        }
        setupNavigaionBar()
        setupProfileImage()
        nameTextField.text = currUser?.name
        if let mySignature = currUser?.signature, mySignature != "" {
            signatureTextView.text = mySignature
            signatureTextView.textColor = .black
            signatureString = mySignature
        }
    }
    
    func setupViewContents(){
        let topCst: CGFloat = UIScreen.main.bounds.height < 600 ? 10 : 20
        
        view.addSubview(nameTextField)
        nameTextField.addConstraints(left: view.leftAnchor, top: topLayoutGuide.bottomAnchor, right: view.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 36 + topCst)
        
        let sideConstant : CGFloat = (UIDevice.current.userInterfaceIdiom == .phone) ? 200 : 360
        let yConstant : CGFloat = (UIDevice.current.userInterfaceIdiom == .phone) ? -80 : -260
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: topCst).isActive = true
        // profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: sideConstant).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: sideConstant).isActive = true
        
        view.addSubview(logoutButton)
        logoutButton.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 60, width: 0, height: 40)
        
        let btmCst: CGFloat = UIScreen.main.bounds.height < 600 ? 5 : 15
        view.addSubview(saveButton)
        saveButton.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: logoutButton.topAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: btmCst, width: 0, height: 40)
        
        view.addSubview(fbLoginButton)
        fbLoginButton.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: logoutButton.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 42)
        
        view.addSubview(signatureTextView)
        signatureTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        signatureTextViewTopconstraint = signatureTextView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: topCst)
        signatureTextViewTopconstraint?.isActive = true
        signatureTextViewTopconstraintOriginConst = signatureTextViewTopconstraint?.constant
        signatureTextView.widthAnchor.constraint(equalToConstant: sideConstant * 1.3).isActive = true
        signatureTextView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -topCst).isActive = true

    }

    func pickImg(){
        let imgPicker = UIImagePickerController()
        imgPicker.navigationBar.tintColor = .white
        imgPicker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        imgPicker.sourceType = .photoLibrary
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        present(imgPicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImg : UIImage?
        if let getEditedImg = info["UIImagePickerControllerEditedImage"] {
            selectedImg = getEditedImg as? UIImage
        }
        else if let originalImg = info["UIImagePickerControllerOriginalImage"] {
            selectedImg = originalImg as? UIImage
        }
        if let getImg = selectedImg {
            profileImageView.image = getImg
            imageDidChanged = true
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imageDidChanged = false
        dismiss(animated: true, completion: nil)
    }
    
    private func fetchUserFromFirebase(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                self.currUser?.setValuesForKeys(dictionary)
            }
        }, withCancel: nil)
    }
    
    private func setupNavigaionBar(){
        navigationItem.title = "My Profile"
    }
    func setupProfileImage(){
        if let imgUrl = currUser?.profileImgURL {
            profileImageView.loadImageUsingCacheWith(urlString: imgUrl)
        }else{
            profileImageView.image = #imageLiteral(resourceName: "guaiqiao01")
        }
    }
    private func setupFbLoginButton(){
        if let tx = fbLoginButton.titleLabel?.text {
            let arr = tx.components(separatedBy: " ")
            fbLoginButton.isHidden = arr.contains("in")
        }else{
            fbLoginButton.isHidden = true
        }
    }

    // for textView:
    private func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func keyboardDidShow(notification: Notification){
        let dy = self.profileImageView.frame.height / 1.5
        guard let sct = self.signatureTextViewTopconstraint?.constant, sct > -dy else { return }
            self.signatureTextViewTopconstraint?.constant = signatureTextViewTopconstraintOriginConst! - dy - 30 //(keyboardFrame.height / 4)
            self.view.layoutIfNeeded()
    }
    func keyboardWillHide(notification: Notification){
            self.signatureTextViewTopconstraint?.constant = self.signatureTextViewTopconstraintOriginConst ?? 20
    }
    // from UITextViewDelegate:
    func textViewDidBeginEditing(_ textView: UITextView) {
        if signatureTextView.text == textViewPlaceholder || signatureTextView.text == "" {
            signatureTextView.text = ""
            signatureTextView.textColor = .black
        }
        signatureTextView.becomeFirstResponder()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if signatureTextView.text == "" {
            signatureTextView.text = textViewPlaceholder
            signatureTextView.textColor = .lightGray
            signatureString = ""
        }else{
            signatureString = signatureTextView.text
        }
        signatureTextView.resignFirstResponder()
    }
    
    // from UITextFieldDelegate:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.removeObserver(self)
        signatureTextView.resignFirstResponder()
        nameTextField.becomeFirstResponder()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameTextField.resignFirstResponder()
        setupKeyboardObservers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        
        let locationTxVw = touch.location(in: self.signatureTextView)
        if locationTxVw.x < 0 || locationTxVw.y < 0 || locationTxVw.x > signatureTextView.frame.maxX {
            textViewDidEndEditing(signatureTextView)
        }
        let locationTxFd = touch.location(in: self.nameTextField)
        if locationTxFd.y > nameTextField.frame.height {
            textFieldDidEndEditing(nameTextField)
        }
    }
    
    
    func saveChangesToFirebase(){
        signatureTextView.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
        guard let userName = currUser?.name, let userEmail = currUser?.email,
              let userId = currUser?.id, let url = currUser?.profileImgURL else { return }
        
        if imageDidChanged == false {
            currUser?.name = nameTextField.text
            currUser?.signature = signatureString
            msgViewController?.currUser.name = nameTextField.text
            updateNewInfoFor(id: userId, newName: nameTextField.text, newSignature: signatureString)
            return
        }
        // else, save with new image: -------------------
        let imgId = "\(userEmail)Profile.jpg" // if need to change this id, also change it in LoginViewController
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(imgId)
        // 1, remove old file from firebase:
        storageRef.delete { (err) in
            if err != nil {
                print("get error when deleting prifile image form firebase: ProfileViewController.swift:saveChangesToFirebase() : ", err)
            }
            //1.1, remove old file form local disk:
            print("  --------- 1.1, remove old img file form local disk.")
            UserDefaults.standard.removeObject(forKey: url)
        }
        // 2, put new image file into it:
        if let pImg = profileImageView.image, let uploadData = UIImageJPEGRepresentation(pImg, 0.1) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("get error when putting user profile image: [ProfileViewController.swift:saveChangesToFirebase()]", error)
                    return
                }
                if let newImgUrl = metadata?.downloadURL()?.absoluteString {
                    self.currUser?.profileImgURL = newImgUrl
                    self.currUser?.name = self.nameTextField.text
                    self.currUser?.signature = self.signatureString
                    self.msgViewController?.currUser.profileImgURL = newImgUrl
                    self.msgViewController?.currUser.name = self.nameTextField.text
                    self.msgViewController?.saveUserIntoDisk()
                    self.saveImageIntoDiskWith(self.profileImageView.image, newImgUrl)
                    self.updateNewInfoFor(id: userId, newName:self.nameTextField.text, newUrl: newImgUrl)
                }
            })
        }
    }
    private func updateNewInfoFor(id: String?, newName:String?, newUrl:String?){
        guard let id = id, let newName = newName, let newUrl = newUrl else { return }
        let userRef = FIRDatabase.database().reference().child("users").child(id)
        let updateDictionary:[String:Any] = ["name":newName, "profileImgURL":newUrl]
        userRef.updateChildValues(updateDictionary) { (error, reference) in
            if error != nil {
                print("get error when updating new user name and imgUrl: ProfileViewController.swift: updateNewInfoFor()", error)
            }
            self.showAlertWith(title: "✅ Update Success!", message: "Your new profile information has been update to database successfully!")
        }
    }
    private func saveImageIntoDiskWith(_ image: UIImage?, _ imgUrl: String?){
        guard let image = image, let imgUrl = imgUrl, imgUrl != "" else { return }
        UserDefaults.standard.set(UIImageJPEGRepresentation(image, 1.0), forKey: imgUrl)
        UserDefaults.standard.synchronize()
    }
    private func updateNewInfoFor(id: String?, newName: String?, newSignature: String?){
        guard let id = id, let newName = newName else { return }
        let newSig = newSignature ?? ""
        let userRef = FIRDatabase.database().reference().child("users").child(id)
        let updateDict : [String:Any] = ["name": newName, "signature": newSig]
        userRef.updateChildValues(updateDict) { (error, reference) in
            if error != nil {
                print("get error when updating new user name and imgUrl: ProfileViewController.swift: updateNewInfoFor()", error)
            }
            self.showAlertWith(title: "✅ Update Success!", message: "Your new profile information has been update to database successfully!")
        }
    }
    
    //=== Menu ==============================================
    lazy var topRightMenuLuncher : ProfileViewMenuLuncher = {
        let m = ProfileViewMenuLuncher()
        m.menuView.backgroundColor = menuColorLightOrange
        return m
    }()
    
    func addButtonTapped(){
        topRightMenuLuncher.addMenuViewShowUp()
    }

    func showBlackList(){
        //use slide-out menu
        
    }
    
    
    
    func handleLogout(){
        tabBarController?.selectedIndex = 0
        self.currUser = nil as User?
        signatureTextView.text = ""
        msgViewController?.handleLogout()
    }

    // facebook login button
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error) {
        if error != nil {
            showAlertWith(title: "‼️Got an Error", message: "Facebook login failed, please try again later. Error: \(error)")
            return
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        handleLogout()
    }

    
    
    private func showAlertWith(title:String, message:String){
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertCtrl.dismiss(animated: true, completion: nil)
        }))
        self.present(alertCtrl, animated: true, completion: nil)
    }
    

}


