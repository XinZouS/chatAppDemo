//
//  ChatLogViewAddingMenu.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/2/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

enum ItemTitle : String {
    case nameCard = "View name card"
    case clear = "Clear chat history"
    case report = "Report this user"
}

struct AddMenuItem {
    var iconImg : UIImage?
    var title   : ItemTitle?
    
    init(title:ItemTitle, icon:UIImage) {
        self.title = title
        self.iconImg = icon
    }
}


class ChatLogAddMenuLuncher : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var chatLogController : ChatLogController?
    
    let transparentBackground = UIView()
    
    let menuView : UIView = {
        let v = UIView()
        v.backgroundColor = menuColorLightPurple
        let screen = UIScreen.main.bounds
        let w : CGFloat = 190, h : CGFloat = 200
        let dx: CGFloat = 16, dy : CGFloat = 80
        v.frame = CGRect(x: screen.width - w - dx, y: dy, width: w, height: h)
        return v
    }()

    let menuCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let v = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        v.backgroundColor = menuColorLightPurple
        return v
    }()
    
    let cellId = "addMenuCellId"
    
    var items = [AddMenuItem]()
    
    
    override init(){
        super.init()
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        menuCollectionView.register(AddMenuCell.self, forCellWithReuseIdentifier: cellId)
        if let layout = menuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 1
            layout.scrollDirection = .vertical
        }
        
        setupAddMenuItems()
        
        let g : CGFloat = 0
        menuView.addSubview(menuCollectionView)
        menuCollectionView.addConstraints(left: menuView.leftAnchor, top: menuView.topAnchor, right: menuView.rightAnchor, bottom: menuView.bottomAnchor, leftConstent: g, topConstent: 10, rightConstent: g, bottomConstent: g, width: 0, height: 0)
    }
    
    private func setupAddMenuItems(){
        let itemViewNameCard = AddMenuItem(title: ItemTitle.nameCard, icon: #imageLiteral(resourceName: "kitten_169x158@1x"))
        let itemClearChatHistory = AddMenuItem(title: ItemTitle.clear, icon: #imageLiteral(resourceName: "paw-print_64x64@1x")) // paw-print_512x512
        let itemReport = AddMenuItem(title: ItemTitle.report, icon: #imageLiteral(resourceName: "catAngryIcon91x91"))
        items = [itemClearChatHistory, itemReport]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! AddMenuCell
        cell.titleLabel.text = items[indexPath.item].title?.rawValue
        cell.imageView.image = items[indexPath.item].iconImg
        cell.backgroundColor = .clear
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: menuView.frame.width, height: 40)
    }
    
    func addMenuViewShowUp(){
        guard let window = UIApplication.shared.keyWindow else { return }
        
        transparentBackground.frame = window.frame
        transparentBackground.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissWithoutSelection)))
        transparentBackground.isHidden = false
        window.addSubview(transparentBackground)
        
        menuView.isHidden = false
        menuView.alpha = 1
        window.addSubview(menuView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < self.items.count, let getTitle = items[indexPath.item].title else { return }
        
        switch getTitle {
        case ItemTitle.nameCard:
            print("-- get user name card")
        case ItemTitle.clear:
            print("-- clear chat history")
        case ItemTitle.report:
            print("-- report this user")
        default:
            dismissWithoutSelection()
        }
    }
    
    func dismissWithoutSelection(){
        UIView.animate(withDuration: 0.5, animations: { 
            self.menuView.alpha = 0
        }, completion: { (complet) in
            self.menuView.isHidden = true
            self.transparentBackground.isHidden = true
        })
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
