//
//  ViewController.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 20/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import UIKit
import GTMAppAuth

struct Album: Codable {
    let id: String
    let title: String
    let coverPhotoBaseUrl: String
}

struct AlbumsList: Codable {
    let albums: [Album]
}

class ViewController: UIViewController {

    @IBOutlet weak var spinningIndicator: UIActivityIndicatorView!
    @IBOutlet weak var connectButton: UIButton!
    
    var albumsStore: AlbumsList!

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumsSegue"
        {
            if let destinationNavigationVC = segue.destination as? UINavigationController {
                if let destinationVC = destinationNavigationVC.viewControllers[0] as? AlbumsCollectionViewController {
                    destinationVC.albumsStore = self.albumsStore
                }
                
            }
        }
    }
    
    @IBAction func connectToGoogle(_ sender: Any) {
        
        // Do any additional setup after loading the view, typically from a nib.
        let authorizationEndpoint = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")
        let tokenEndpoint = URL(string: "https://www.googleapis.com/oauth2/v4/token")
        let redirectURI = URL(string: "com.googleusercontent.apps.352311706242-36tn80abmul73hpdrolhh4kt826tljrj:/oauthredirect")
        
        let clientId = "352311706242-36tn80abmul73hpdrolhh4kt826tljrj.apps.googleusercontent.com"
        
        let delegate = UIApplication.shared.delegate! as! AppDelegate
        
        let configuration = OIDServiceConfiguration(authorizationEndpoint: authorizationEndpoint!, tokenEndpoint: tokenEndpoint!)
   
        let request = OIDAuthorizationRequest.init(
            configuration: configuration,
            clientId: clientId,
            clientSecret: nil,
            scopes: [OIDScopeOpenID, OIDScopePhone, "https://www.googleapis.com/auth/photoslibrary.readonly", "https://www.googleapis.com/auth/photoslibrary", "https://www.googleapis.com/auth/photoslibrary.readonly.appcreateddata"],
            redirectURL: redirectURI!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )
        
        delegate.currentAuthorizationSession = OIDAuthorizationService.present(request, presenting: self) { (authResponse: OIDAuthorizationResponse?, error: Error?) in
            guard let authorizationCode = authResponse?.authorizationCode else {
                // self.showError(error: error!)
                return
            }
            
            let tokenRequest = OIDTokenRequest.init(
                configuration: configuration,
                grantType: "authorization_code",
                authorizationCode: authorizationCode,
                redirectURL: redirectURI!,
                clientID: clientId,
                clientSecret: nil,
                scope: nil,
                refreshToken: nil,
                codeVerifier: request.codeVerifier!,
                additionalParameters: nil
            )
            
            OIDAuthorizationService.perform(tokenRequest) { (tokenResponse : OIDTokenResponse?, error : Error?) in
                guard let accessToken = tokenResponse?.accessToken else {
                    // self.showError(error: error!)
                    return
                }
                
                self.spinningIndicator.isHidden = false
                self.connectButton.isEnabled = false
                
                SharedAPI.accessToken = accessToken

                SharedAPI.getAlbums(completion: { (albumsList) in
                    self.albumsStore = albumsList
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "albumsSegue", sender: self)
                    }
                })
            }
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
