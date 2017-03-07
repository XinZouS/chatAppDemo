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
    
    func loginOrRegister(){ // handleLogin(): loginSignup button tapped():
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            performSelector(inBackground: #selector(loginUser), with: nil)
        }else{
            performSelector(inBackground: #selector(registerUser), with: nil)
        }
    }
    //
    func loginUser(){
        guard let email = emailTextField.text, let pw = passwordTextField.text else {
            print("need your email and password!!!")
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: pw, completion: { (user:FIRUser?, err:Error?) in
            if err != nil {
                print("get error wen sign in: \(err!)")
                return
            }
            // see user login successfully:
            if user?.email != nil {
                self.messagesViewController?.fetchUserAndSetUpNavBarTitle() // update navBar.title
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    //
    func registerUser(){
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text
            else {
                print("please provide your name, email and password!!!")
                return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user:FIRUser?, err) in
            if err != nil {
                print("get error when creating new user: \(err!), [LoginViewController+Ex.swift:86]")
                return
            }
            
            // use fireBase User:
            guard let uid = user?.uid else {
                print("did NOT access to current user: LoginViewController.swift: 93")
                return
            }
            
            //--- when new user successfully ----------------
            // use fireBase storage to save image:
            let imageId = NSUUID().uuidString
//            let storageRef = FIRStorage.storage().reference().child("\(name)_\(imageId).png") // add .child(name) or it will crash;
//            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(name)_\(imageId).png") // add more .child();
            let storageRef = FIRStorage.storage().reference().child("profile_images").child("\(name)_\(imageId).jpg") // add more .child();
            
            //if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
            //if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) { // make img smaller!
            // a safer way to get image data upload: 
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.put(uploadData, metadata: nil, completion: {(metadata, error) in
                    if error != nil {
                        print("get error when putting user profile image: [LoginViewController+Ex.swift:109]", error)
                        return
                    }
                    
                    if let profileImgURL = metadata?.downloadURL()?.absoluteString {
                        let friends : [String:Bool] = ["8JXr5B5njGWdgk2QP34OeFt8UlF3":false] // test case: default friend
                        // let userValue = ["name":name, "email":email, "profileImgURL":metadata.downloadUrl()]
                        let userValue = ["name":name, "email":email, "profileImgURL":profileImgURL, "friends":friends] as [String:Any]
                        self.registerUserIntoDatabaseWithUID(uid: uid, userValue: userValue)
                        //print(metadata)  // to get its info and key;
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
    

}
