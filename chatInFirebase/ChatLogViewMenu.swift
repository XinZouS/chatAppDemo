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
            layout.minimumLineSpacing = 0
        }
        
        setupMenuItems()
    }
    
    private func setupMenuItems(){
        let mImage = MenuItem(MenuString.Image, UIImage(named: "bear02n80x80")! )
        let mCamera = MenuItem(MenuString.Camera, UIImage(named: "catNdog80x80@1x")! )
        let mGifs  = MenuItem(MenuString.Gifs, UIImage(named: "bear02n80x80")! )
        menuItems = [mImage, mCamera, mGifs]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuItems.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: menuCellId, for: indexPath) as! MenuCell
        cell.backgroundColor = .orange
        let item = menuItems[indexPath.item]
        cell.imageViwe.image = item.icon
        cell.titleLabel.text = item.name.rawValue
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let margin : CGFloat = 0
        let sideLen = UIScreen.main.bounds.width / 4 - margin
        return CGSize(width: sideLen, height: sideLen)
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
        blackBackground.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(menuViewDismissForSelected)))
        window.addSubview(blackBackground)
        
        // init position for menu
        let height = CGFloat(window.frame.height / 3)
        collectionMenuView.frame = CGRect(x: 0, y: window.frame.maxY, width: window.frame.width, height: 0)
        window.addSubview(collectionMenuView)
        
        let dy = chatLogController?.inputContainerView.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.collectionMenuView.frame = CGRect(x: 0, y: window.frame.height - height - dy!, width: window.frame.width, height: height)
            self.blackBackground.alpha = 0.5
        }, completion: nil)
    }
    
    func menuViewDismissForSelected(item: MenuItem?){
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.2, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackBackground.alpha = 0
            if let currWindow = UIApplication.shared.keyWindow {
                self.collectionMenuView.frame = CGRect(x: 0, y: currWindow.frame.maxY, width: currWindow.frame.width, height: 0)
            }
        }) { (finish) in
            self.blackBackground.isHidden = true
//            guard let item = item, item < self.menuItems.count else { return }
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
    
}


class MenuCell : UICollectionViewCell {
    
    var imageViwe : UIImageView = {
        let i = UIImageView()
        i.contentMode = .scaleAspectFit
        return i
    }()
    
    var titleLabel : UILabel = {
        let t = UILabel()
        t.backgroundColor = .yellow
        t.font = UIFont.systemFont(ofSize: 16)
        t.textColor = .gray
        t.text = "titleLabel"
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageViwe)
        imageViwe.addConstraints(left: leftAnchor, top: topAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 30, width: 0, height: 0)
        
        addSubview(titleLabel)
        titleLabel.addConstraints(left: leftAnchor, top: imageViwe.bottomAnchor, right: rightAnchor, bottom: bottomAnchor, leftConstent: 0, topConstent: 0, rightConstent: 0, bottomConstent: 0, width: 0, height: 0)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

