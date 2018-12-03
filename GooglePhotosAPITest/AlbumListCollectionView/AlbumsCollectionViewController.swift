//
//  AlbumsCollectionViewController.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 21/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

class AlbumsCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet var collectionView: UICollectionView!
    
    var albumsStore: AlbumsList!
    var selectedAlbum: Album!
    var selectedAlbumItems: AlbumItems!
    
    var refresher:UIRefreshControl!
    
    var waitIndicatorView: UIView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "albumSegue"
        {
            if let destinationVC = segue.destination as? AlbumCollectionViewController {
                destinationVC.albumStore = self.selectedAlbum
                destinationVC.itemsStore = self.selectedAlbumItems
            }

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        //self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(refreshAlbums), for: .valueChanged)
        self.collectionView!.refreshControl = refresher
        self.navigationItem.title = NSLocalizedString("myAlbums", comment: "My albums")
    }
    
    @objc func refreshAlbums() {
        SharedAPI.getAlbums { (albumsList) in
            self.albumsStore = albumsList
            self.stopRefresher() 
        }
    }
    
    func stopRefresher() {
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsStore.albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! AlbumsCollectionViewCell
        let album = albumsStore.albums[indexPath.row]
        
        cell.displayContent(imageUrl: album.coverPhotoBaseUrl, title: album.title)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.bounds.width
        
        var itemsPerLine = 0
        
        if screenWidth < 500 {
            itemsPerLine = 2
        } else if screenWidth < 1000 {
            itemsPerLine = 3
        } else {
            itemsPerLine = 4
        }
        
        let width = (Int(screenWidth) - (10 + ( itemsPerLine * 10 ))) / itemsPerLine
        let height = width
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    
    func displayWaitIndicator() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let navigationBarHeight = self.navigationController?.navigationBar.bounds.height
        
        let center = CGPoint.init(x: (screenWidth / 2), y: (screenHeight / 2) - navigationBarHeight!)
        
        let waitIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        waitIndicator.frame = CGRect.init(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        waitIndicator.center = center
        //waitIndicator.hidesWhenStopped = true
        waitIndicator.startAnimating()
        
        let loadingBackground = UIView.init()
        loadingBackground.frame = CGRect.init(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
        loadingBackground.center = center
        loadingBackground.backgroundColor = UIColor.init(red: 68.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 0.7)
        loadingBackground.layer.cornerRadius = 10
        
        waitIndicatorView = UIView.init()
        waitIndicatorView.frame = collectionView.frame
        waitIndicatorView.center = collectionView.center
        
        waitIndicatorView.addSubview(loadingBackground)
        waitIndicatorView.addSubview(waitIndicator)
        
        collectionView.addSubview(waitIndicatorView)
    }
    
    func removeWaitIndicator() {
        waitIndicatorView?.removeFromSuperview()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        displayWaitIndicator()
        
        let album = albumsStore.albums[indexPath.row]

        self.selectedAlbum = album
        
        SharedAPI.getAlbum (albumId: album.id, nextToken: nil) { (itemsList) in
            self.selectedAlbumItems = itemsList

            DispatchQueue.main.async {
                self.removeWaitIndicator()
                self.performSegue(withIdentifier: "albumSegue", sender: self)
            }
         }

    }
    
}
