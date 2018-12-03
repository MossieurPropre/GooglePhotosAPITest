//
//  CopyPopoverViewController.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 28/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

class CopyPopoverViewController: UIViewController {
    
    var baseUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss()
    }
    
    @IBAction func bbCodeTouchedUp(_ sender: Any) {
        UIPasteboard.general.string = "[url=" + baseUrl + "=w1920-h1080][img]https://reho.st/" + baseUrl + "=w800-h450[/img][/url]"
        dismiss()
    }
    
    @IBAction func fullHDTouchedUp(_ sender: Any) {
        UIPasteboard.general.string = "https://reho.st/" + baseUrl + "=w1920-h1080"
        dismiss()
    }
    
    func dismiss() -> Void {
        self.dismiss(animated: true) {
            
        }
    }
}
