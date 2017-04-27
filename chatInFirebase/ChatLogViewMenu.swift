//
//  ChatLogViewMenu.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/26/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


enum MenuString : String {
    case Image  = "Image"
    case Camera = "Camera"
    case Gifs   = "Gifs"
}

class MenuItem : NSObject {
    
    let name: MenuString
    let icon: UIImage
    
    init(_ nameStr: MenuString, _ iconImg: UIImage){
        self.name = nameStr
        self.icon = iconImg
    }
}


class ChatLogViewMenuLuncher : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var chatLogController : ChatLogController?
    
    let blackBackground = UIView()
    
    let menuView : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    let collectionMenuView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = .white
        
        return v
    }()
    
    let menuCellId = "menuCellId"
    
    var menuItems = [MenuItem]()
    
    
    override init() {
        super.init()
        
        collectionMenuView.delegate = self
        collectionMenuView.dataSource = self
        
        collectionMenuView.register(MenuCell.self, forCellWithReuseIdentifier: menuCellId)
        if let layout = collectionMenuView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
        }
        
        setupMenuItems()
        
        menuView.addSubview(collectionMenuView)
        collectionMenuView.addConstraints(left: menuView.leftAnchor, top: menuView.topAnchor, right: menuView.rightAnchor, bottom: menuView.bottomAnchor, leftConstent: 20, topConstent: 20, rightConstent: 20, bottomConstent: 20, width: 0, height: 0)
    }
    
    private func setupMenuItems(){
        let mImage = MenuItem(MenuString.Image, UIImage(named: "photoGallery80x80")! )
        let mCamera = MenuItem(MenuString.Camera, UIImage(named: "camera122x122")! )
        let mGifs  = MenuItem(MenuString.Gifs, UIImage(named: "guaiqiao80x80")! )
        menuItems = [mImage, mCamera]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuCellId, for: indexPath) as! MenuCell
        // cell.backgroundColor = .orange
        let item = menuItems[indexPath.item]
        cell.imageViwe.image = item.icon.withRenderingMode(.alwaysTemplate)
        cell.tintColor = .gray
        cell.titleLabel.text = item.name.rawValue
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 4 : 6
        let margin : CGFloat = 30
        let sideLen = UIScreen.main.bounds.width / ratio - margin
        return CGSize(width: sideLen + 10, height: sideLen)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        menuViewDismissForSelected(item: menuItems[indexPath.item])
    }
    
    func menuViewShowup(){
        
        guard let window = UIApplication.shared.keyWindow else { return }
        blackBackground.isHidden = false
        blackBackground.frame = window.frame
        blackBackground.backgroundColor = .black
        blackBackground.alpha = 0
        blackBackground.isUserInteractionEnabled = true
        blackBackground.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(menuViewDismiss)))
        window.addSubview(blackBackground)
        
        // init position for menu
        let height = CGFloat(window.frame.height / 4)
//        collectionMenuView.frame = CGRect(x: 0, y: window.frame.maxY, width: window.frame.width, height: 0)
//        window.addSubview(collectionMenuView)
        menuView.frame = CGRect(x: 0, y: window.frame.maxY, width: window.frame.width, height: 0)
        window.addSubview(menuView)
        
        let dy = chatLogController?.inputContainerView.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
//            self.collectionMenuView.frame = CGRect(x: 0, y: window.frame.height - height - dy!, width: window.frame.width, height: height)
            self.menuView.frame = CGRect(x: 0, y: window.frame.height - height - dy!, width: window.frame.width, height: height)
            self.blackBackground.alpha = 0.5
        }, completion: nil)
    }
    
    func menuViewDismissForSelected(item: MenuItem?){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.blackBackground.alpha = 0
            if let currWindow = UIApplication.shared.keyWindow {
//                self.collectionMenuView.frame = CGRect(x: 0, y: currWindow.frame.maxY, width: currWindow.frame.width, height: 0)
                self.menuView.frame = CGRect(x: 0, y: currWindow.frame.maxY, width: currWindow.frame.width, height: 0)
            }
        }) { (finish) in
            self.blackBackground.isHidden = true
            guard let itemName = item?.name else { return }
            switch itemName {
            case MenuString.Image:
                self.chatLogController?.selectingImage(fromCamera: false)
            case MenuString.Camera:
                self.chatLogController?.selectingImage(fromCamera: true)
            case MenuString.Gifs:
                print(" -- selecting at 0: \(self.menuItems[2].name.rawValue)")
            default:
                return
            }
        }
    }
    func menuViewDismiss(){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.blackBackground.alpha = 0
            if let currWindow = UIApplication.shared.keyWindow {
//                self.collectionMenuView.frame = CGRect(x: 0, y: currWindow.frame.maxY, width: currWindow.frame.width, height: 0)
                self.menuView.frame = CGRect(x: 0, y: currWindow.frame.maxY, width: currWindow.frame.width, height: 0)
            }
        }) { (finish) in
            self.blackBackground.isHidden = true
        }
    }
    
}





