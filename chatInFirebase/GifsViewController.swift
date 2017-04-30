//
//  GifsViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 4/28/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


class GifItem : NSObject {
    
    var imgUrl: String?
    var image : UIImage?
    
    init(url:String?, gif:UIImage?) {
        self.imgUrl = url
        self.image = gif
    }
}


class GifsViewController : NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var currUser : User?
    var chatLogController : ChatLogController?
    
    let blackBackground = UIView()
    
    let menuView : UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    let collectionGifsView : UICollectionView = {
        let v = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        v.backgroundColor = .white
        return v
    }()
    
    private let cellId = "gifCellId"
    
    var myGifs = [GifItem]()


    override init() {
        super.init()
        
        collectionGifsView.delegate = self
        collectionGifsView.dataSource = self
        
        collectionGifsView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        
        menuView.addSubview(collectionGifsView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionGifsView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) 
        cell.backgroundColor = .green
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 4 : 6
        let margin : CGFloat = 30
        let sideLen = UIScreen.main.bounds.width / ratio - margin
        return CGSize(width: sideLen, height: sideLen)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let gifItem = myGifs[indexPath.item]
        gifsViewDismissWithSelecting(item: gifItem)
    }
    
    
    func gifMenuViewShowup(){
        guard let window = UIApplication.shared.keyWindow else { return }
        blackBackground.frame = window.frame
        blackBackground.backgroundColor = .black
        blackBackground.alpha = 0
        blackBackground.isHidden = false
        blackBackground.isUserInteractionEnabled = true
        blackBackground.addGestureRecognizer( UITapGestureRecognizer(target: self, action: #selector(gifsViewDismissWithoutSelection)))
        window.addSubview(blackBackground)
        
        let ratio : CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 0.65 : 0.4
        let menuHeigh = CGFloat(window.frame.height * ratio)
        menuView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: menuHeigh)
        window.addSubview(menuView)
        
        let dy = chatLogController?.inputContainerView.frame.height
        self.blackBackground.alpha = 0.5
        self.menuView.frame = CGRect(x: 0, y: window.frame.height - menuHeigh + dy!, width: window.frame.width, height: menuHeigh)
    }
    
    private func gifsViewDismissWithSelecting(item: GifItem){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.2, options: .curveLinear, animations: {
            guard let window = UIApplication.shared.keyWindow else { return }
            self.blackBackground.alpha = 0
            self.menuView.frame = CGRect(x: 0, y: window.frame.maxY, width: window.frame.width, height: 0)
        }) { (complete) in
            self.blackBackground.isHidden = true
            self.chatLogController?.prepareUploadingGif(item: item)
        }
    }
    
    func gifsViewDismissWithoutSelection(){
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.2, options: .curveLinear, animations: {
            guard let window = UIApplication.shared.keyWindow else { return }
            self.blackBackground.alpha = 0
            self.menuView.frame = CGRect(x: 0, y: window.frame.maxY, width: window.frame.width, height: 0)
        }) { (complete) in
            self.blackBackground.isHidden = true
        }
    }
    
}




class GifsCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .green
        
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

