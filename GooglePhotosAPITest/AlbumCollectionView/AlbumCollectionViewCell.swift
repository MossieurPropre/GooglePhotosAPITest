//
//  AlbumCollectionViewCell.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 22/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    
    func displayContent(image: UIImage) {
            itemImageView.image = image
    }
}
