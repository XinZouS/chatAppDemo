//
//  LoginViewController+Ex.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/2/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

extension LoginViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectingImageView(){
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .photoLibrary
        imgPicker.delegate = self // it needs UINavigationControllerDelegate, and func ..DidCancel()
        imgPicker.allowsEditing = true
        
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print(info) // to see the key of image file been returned, copy its key:
        
        var selectedImgFromPicker : UIImage?
        
        if let editedImg = info["UIImagePickerControllerEditedImage"] {
            // get EditedImage:
            selectedImgFromPicker = editedImg as? UIImage
        }else
        if let originalImg = info["UIImagePickerControllerOriginalImage"] {
            // get originalImage:
            selectedImgFromPicker = originalImg as? UIImage
        }
        
        if let getImg = selectedImgFromPicker {
            profileImageView.image = getImg
        }
        
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled img............")
        dismiss(animated: true, completion: nil)
    }
    
    
    //=== save user data into fierbase ======================================================
    
    func loginOrRegister(){
        if emailTextField.text == "" || passwordTextField.text == "" {
            showAlertWith(title: "Missing Info", message: "You need to input both your email and password. Please try again.")
            return
        }
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 { // loginUser or register user
            performSelector(inBackground: #selector(loginUser), with: nil)
        }else{
            let pw1 = passwordTextField.text, pw2 = passwordConfernTextField.text
            if (pw1?.characters.count)! < 8 || (pw2?.characters.count)! < 8 {
                showAlertWith(title: "Password too short", message: "Your password must have at least 8 characters, try again please.")
                return
            }
            if pw1 != pw2 {
                showAlertWith(title: "Password does not match", message: "Both passwords are not the same, please try again.")
                return
            }
            performSelector(inBackground: #selector(registerUser), with: nil)
        }
    }
    
    //
    func loginUser(){
        guard let email = emailTextField.text, let pw = passwordTextField.text else {
            showAlertWith(title: "Missing Info", message: "You need to input both your email and password. Please try again.")
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: pw, completion: { (user:FIRUser?, err:Error?) in
            if err != nil {
                self.showAlertWith(title: "Login Failed", message: "Got an error when signing in: \(err!)")
                print("get error when sign in: LoginViewController+Ex:loginUser(): \(err!)")
                return
            }
            // see user login successfully:
            if user?.email != nil {
                self.messagesViewController?.currUser.id = user?.uid
                self.messagesViewController?.currUser.email = user?.email
                self.messagesViewController?.saveUserIntoDisk()
                self.messagesViewController?.fetchUserAndSetUpNavBarTitle() // update navBar.title
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    //
    func registerUser(){
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            showAlertWith(title: "Please tell us more about you", message: "please provide your name, email and password to register.")
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user:FIRUser?, err) in
            if err != nil {
                self.showAlertWith(title: "Register Failed", message: "Got an error when register new user: \(err!)")
                print("get error when creating new user: [LoginViewController+Ex.registerUser()]: \(err!)")
                return
            }
            
            // use fireBase User:
            guard let uid = user?.uid else {
                print("------- did NOT access to current user: LoginViewController.swift:registerUser()")
                return
            }
            //--- when new user successfully ----------------
            // use fireBase storage to save image:
            let imageId = "\(email)Profile.jpg" // NSUUID().uuidString
            let storageRef = FIRStorage.storage().reference().child("profile_images").child(imageId) // add more .child();
            
            //if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {  // png is too big
            //if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) { // make img smaller!
            // a safer way to get image data upload: 
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: {(metadata, error) in
                    if error != nil {
                        print("get error when putting user profile image: [LoginViewController+Ex.swift:109]", error!)
                        return
                    }                    
                    if let profileImgURL = metadata?.downloadURL()?.absoluteString {
                        let friends : [String] = [""]
                        // let userValue = ["name":name, "email":email, "profileImgURL":metadata.downloadUrl()]
                        let userValue = ["name":name, "email":email, "profileImgURL":profileImgURL, "friends":friends] as [String:Any]
                        self.registerUserIntoDatabaseWithUID(uid: uid, userValue: userValue)
                        //print(metadata)  // to get its info and key;
                        
                        self.loginUser() // for user image refresh after new user register
                    }
                })
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid:String, userValue: [String:Any] ) {
        let ref = FIRDatabase.database().reference() //(fromURL: "https://chatdemo-4eb7c.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        
        // demo: ref.updateChildValues(["Key" : "value"])
        userReference.updateChildValues(userValue, withCompletionBlock: { (err, ref) in
            if err != nil {
                print("getting err when updating user info, [LoginViewController+Ex.swift:133]: \(err!)")
                return
            }
            // self.messagesViewController?.fetchUserAndSetUpNavBarTitle() // replaced by following:
            // self.messagesViewController?.navigationItem.title = userValue["name"] as? String
            // the above one line can only set title.text, we need add img: 
            let user = User()
            user.setValuesForKeys(userValue)
            self.messagesViewController?.setupNavBarWithUser(user: user) // add img and title.text;
            
            self.dismiss(animated: true, completion: nil)
            print("save user info successful into firebase DB!!!")
            
        })

    }
    
    private func showAlertWith(title:String, message:String){
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertCtrl.dismiss(animated: true, completion: nil)
        }))
        self.present(alertCtrl, animated: true, completion: nil)
    }
    

    

}
