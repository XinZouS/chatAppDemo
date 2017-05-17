//
//  ProfileViewMenuLuncher.swift
//  chatInFirebase
//
//  Created by Xin Zou on 5/15/17.
//  Copyright © 2017 Xin Zou. All rights reserved.
//

import UIKit


class ProfileViewMenuLuncher : SmallTopRightMenuLuncher {
    
    var profileVC : ProfileViewController?
    
    
    override init() {
        super.init()
        
        setupMenuItems()
                
    }
    
    private func setupMenuItems(){
        let seeBlackList = AddMenuItem(title: ItemTitle.blackList, icon: #imageLiteral(resourceName: "dogStopIcon150x150"))
        items = [seeBlackList]
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < self.items.count, let getTitle = items[indexPath.row].title else { return }

        switch getTitle {
        case ItemTitle.blackList:
            profileVC?.showBlackList()
        default:
            dismissWithoutSelection()
        }
        dismissWithoutSelection()

    }
    
}
