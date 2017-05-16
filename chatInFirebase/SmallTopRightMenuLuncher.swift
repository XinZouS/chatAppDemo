//
//  SmallTopRightMenuLuncher.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/15/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


enum ItemTitle : String {
    case nameCard = "View name card"
    case clear = "Clear chat history"
    case report = "Report this user"
    case blockUser = "Block this user"
    
    case blackList = "My black list"
}

struct AddMenuItem {
    var iconImg : UIImage?
    var title   : ItemTitle?
    
    init(title:ItemTitle, icon:UIImage) {
        self.title = title
        self.iconImg = icon
    }
}

class SmallTopRightMenuLuncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let transparentBackground = UIView()
    
    let cellId = "addMenuCellId"
    
    let cellHeight: CGFloat = 40
    
    var items = [AddMenuItem](){
        didSet{
            let screen = UIScreen.main.bounds
            let w : CGFloat = 190, h : CGFloat = CGFloat(items.count) * cellHeight + 20
            let dx: CGFloat = 16, dy : CGFloat = 80
            menuView.frame = CGRect(x: screen.width - w - dx, y: dy, width: w, height: h)
        }
    }
    
    let menuView : UIView = {
        let v = UIView()
        v.backgroundColor = menuColorLightPurple
        return v
    }()
    
    let menuCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let v = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: layout)
        v.backgroundColor = menuColorLightPurple
        return v
    }()
    
    
    override init() {
        super.init()
        
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        menuCollectionView.register(AddMenuCell.self, forCellWithReuseIdentifier: cellId)
        if let layout = menuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 1
            layout.scrollDirection = .vertical
        }
        
        let g : CGFloat = 0
        menuView.addSubview(menuCollectionView)
        menuCollectionView.addConstraints(left: menuView.leftAnchor, top: menuView.topAnchor, right: menuView.rightAnchor, bottom: menuView.bottomAnchor, leftConstent: g, topConstent: 10, rightConstent: g, bottomConstent: g, width: 0, height: 0)
        
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
        return CGSize(width: menuView.frame.width, height: cellHeight)
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
    
    func dismissWithoutSelection(){
        UIView.animate(withDuration: 0.5, animations: {
            self.menuView.alpha = 0
        }, completion: { (complet) in
            self.menuView.isHidden = true
            self.transparentBackground.isHidden = true
        })
    }
    
    
    
}

