//
//  PhotoCell.swift
//  pixel-city
//
//  Created by Sophie Berger on 30.12.18.
//  Copyright © 2018 SophieMBerger. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    override init(frame: CGRect) {
        //        pass in frame form initializer of cell in MapVC
        super.init(frame: frame)
    }
    
//    needed to use custom collection view cell
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
