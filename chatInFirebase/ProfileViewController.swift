//
//  ProfileViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/7/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var msgViewController : MessagesViewController?
    var currUser: User?
    
    let nameTextField : UITextField = {
        let l = UITextField()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.backgroundColor = UIColor(r: 246, g: 230, b: 255) // .clear
        l.font = UIFont.systemFont(ofSize: 20)
        l.textAlignment = .center
        l.text = "My Name here~~"
        return l
    }()
    
    lazy var profileImageView : UIImageView = {
        let i = UIImageView()
        i.translatesAutoresizingMaskIntoConstraints = false
        i.contentMode = .scaleAspectFit
        i.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(pickImg)))
        i.isUserInteractionEnabled = true
        i.image = #imageLiteral(resourceName: "guaiqiao01")
        return i
    }()
    
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
//        updateUserAndView()
        
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 260).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 260).isActive = true
        
        view.addSubview(nameTextField)
        nameTextField.addConstraints(left: view.leftAnchor, top: topLayoutGuide.bottomAnchor, right: view.rightAnchor, bottom: nil, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 46)
        
        view.addSubview(logoutButton)
        logoutButton.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: view.bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 60, width: 0, height: 40)
        
        view.addSubview(saveButton)
        saveButton.addConstraints(left: view.leftAnchor, top: nil, right: view.rightAnchor, bottom: logoutButton.topAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 15, width: 0, height: 40)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserAndView()
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
    }
    
    func pickImg(){
        let imgPicker = UIImagePickerController()
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
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUserFromFirebase(){
        guard let uid = FIRAuth.auth()?.currentUser?.uid else { return }
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: Any] {
                self.currUser?.setValuesForKeys(dictionary)
            }
        }, withCancel: nil)
    }
    
    func setupNavigaionBar(){
        navigationItem.title = "My Profile"
    }
    func setupProfileImage(){
        if let imgUrl = currUser?.profileImgURL {
            profileImageView.loadImageUsingCacheWith(urlString: imgUrl)
        }else{
            profileImageView.image = #imageLiteral(resourceName: "guaiqiao01")
        }
    }

    
    func saveChangesToFirebase(){
        guard let userName = currUser?.name, let userEmail = currUser?.email, let userId = currUser?.id else { return }
        let imgId = "\(userEmail)Profile.jpg"
        let storageRef = FIRStorage.storage().reference().child("profile_images").child(imgId)
        // 1, remove old file from firebase:
        storageRef.delete { (err) in
            if err != nil {
                print("get error when deleting prifile image form firebase: ProfileViewController.swift:saveChangesToFirebase() : ", err!)
                //return
            }
        } // 2, put new image file into it:
        if let pImg = profileImageView.image, let uploadData = UIImageJPEGRepresentation(pImg, 0.1) {
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("get error when putting user profile image: [ProfileViewController.swift:saveChangesToFirebase()]", error!)
                    return
                }
                if let newImgUrl = metadata?.downloadURL()?.absoluteString {
                    self.currUser?.profileImgURL = newImgUrl
                    self.currUser?.name = self.nameTextField.text
                    self.msgViewController?.currUser.profileImgURL = newImgUrl
                    self.msgViewController?.currUser.name = self.nameTextField.text
                    self.msgViewController?.saveUserIntoDisk()
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
                print("get error when updating new user name and imgUrl: ProfileViewController.swift: updateNewInfoFor()", error!)
            }
            //print(reference)
            self.showAlertWith(title: "Update Success!", message: "Your new profile information has been update to database successfully!")
        }

    }
    
    func handleLogout(){
        tabBarController?.selectedIndex = 0
        self.currUser = nil as User?
        msgViewController?.handleLogout()
    }
    
    private func showAlertWith(title:String, message:String){
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertCtrl.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            alertCtrl.dismiss(animated: true, completion: nil)
        }))
        self.present(alertCtrl, animated: true, completion: nil)
    }
    

}


