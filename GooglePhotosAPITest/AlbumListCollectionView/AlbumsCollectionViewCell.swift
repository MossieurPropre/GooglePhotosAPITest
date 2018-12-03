//
//  AlbumsCollectionViewCell.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 21/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

class AlbumsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    
    func displayContent(imageUrl: String, title: String) {
        do {
            let url = URL(string: imageUrl + "=w200-h200")
            let imageData = try Data(contentsOf: url!)
            
            mainImageView.image = UIImage.init(data: imageData)
            titleView.text = title
        } catch let err {
            print(err)
        }
    }
}
