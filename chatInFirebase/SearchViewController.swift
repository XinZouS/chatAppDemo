//
//  SearchViewController.swift
//  chatInFirebase
//
//  Created by Xin Zou on 1/19/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit

class SearchViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var searchingResults = [User]()
    
    lazy var inputContainerView : ChatInputContainerView = {
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        let c = ChatInputContainerView(frame: frame)
        
        return c
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return true
        }
    }
    
    let cellId = "searchCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 90, right: 0) // margin ??????
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(r: 240, g: 230, b: 252)
        collectionView?.register(SearchViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        setupKeyboardObserver()
    }
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveCollectionViewWhenKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    func moveCollectionViewWhenKeyboardDidShow() {
        print("TODO: move collectionView to bottom: SearchViewController.swift:50")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    // handle rotate between landscape and vertical:
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    // setup session of cells: ========================================
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchingResults.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! SearchViewCell
        
        
        return cell
    }
    
    
}
