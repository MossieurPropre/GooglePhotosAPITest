//
//  ItemViewController.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 23/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

class ItemViewController: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var itemView: UIImageView!
    @IBOutlet var mainView: UIView!
    
    var imageUrl: String!
    
    var image: UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "shareSegue"
        {
            if let destinationVC = segue.destination as? UINavigationController {
                if let destinationShareVC = destinationVC.viewControllers[0] as? CopyPopoverViewController {
                    let buttons = self.navigationItem.rightBarButtonItems!
                    
                    var senderButton: UIBarButtonItem!
                    
                    for button in buttons {
                        if (button.title == "Share") {
                            senderButton = button
                        }
                    }
                    
                    destinationVC.popoverPresentationController?.barButtonItem = senderButton
                    destinationShareVC.baseUrl = self.imageUrl
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.hidesBarsOnTap = true
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.tintColor = .white

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        let copyButton = UIBarButtonItem(title: NSLocalizedString("share", comment: "Share"), style: .plain, target: self, action: #selector(copyToClipboard(_:)))
        let saveButton = UIBarButtonItem(title: NSLocalizedString("save", comment: "Save"), style: .plain, target: self, action: #selector(saveToCameraRoll))
        
        self.navigationItem.rightBarButtonItems = [saveButton, copyButton]
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        mainView.isUserInteractionEnabled = true
        mainView.addGestureRecognizer(panGesture)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.hidesBarsOnTap = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.tintColor = UIColor(red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let url = URL(string: imageUrl + "=w1920-h1080")

            let imageData = try Data(contentsOf: url!)

            self.image = UIImage.init(data: imageData)
            itemView.image = self.image

        } catch let err {
            print(err)
        }
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        if (sender.numberOfTouches == 0) {
            let translation = sender.translation(in: self.mainView)
            if (translation.y > 50) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func copyToClipboard(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "shareSegue", sender: self)
    }
    
    @objc func saveToCameraRoll() {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
    }
}
