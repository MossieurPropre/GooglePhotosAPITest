//
//  AlbumCollectionViewController.swift
//  GooglePhotosAPITest
//
//  Created by Christman, Aurelien (BCG Platinion) on 22/11/2018.
//  Copyright © 2018 Christman, Aurelien. All rights reserved.
//

import Foundation
import UIKit

struct AlbumItem: Codable {
    let id: String
    let baseUrl: String
    let filename: String
}

struct AlbumItems: Codable {
    var mediaItems: [AlbumItem]
    var nextPageToken: String?
}

class AlbumCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var collectionView: UICollectionView!
    
    var albumStore: Album!
    var itemsStore: AlbumItems!
    var selectedItem: AlbumItem!
    
    let itemsCache = NSCache<NSString, UIImage>()
    
    var refresher:UIRefreshControl!
    
    var waitIndicatorView: UIView!
    
    var isLoadingContent = false
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "itemSegue"
        {
            if let destinationVC = segue.destination as? ItemViewController {
                destinationVC.imageUrl = self.selectedItem.baseUrl
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refresher = UIRefreshControl()
        //self.refresher.tintColor = UIColor.red
        self.refresher.addTarget(self, action: #selector(refreshItems), for: .valueChanged)
        self.collectionView!.refreshControl = refresher
        self.navigationItem.title = self.albumStore.title
    }
    
    @objc func refreshItems() {
        SharedAPI.getAlbum (albumId: albumStore.id, nextToken: nil) { (itemsList) in
            self.itemsStore = itemsList
            self.stopRefresher()
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> ()) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                completion(UIImage(data: data))
            }
        }
    }
    
    func stopRefresher() {
        DispatchQueue.main.async(execute: {
            self.collectionView.reloadData()
            self.refresher.endRefreshing()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemsStore.mediaItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionFooter = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewLoadingIndicator", for: indexPath) as? UICollectionReusableView {
            return sectionFooter
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: AlbumCollectionViewCell
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! AlbumCollectionViewCell

        let item = itemsStore.mediaItems[indexPath.row]
        
        
        if let cachedImage = itemsCache.object(forKey: NSString.init(string: item.id))  {
            cell.displayContent(image: cachedImage)
        } else {
            DispatchQueue.main.async(qos: DispatchQoS.background) {
                let url = URL(string: item.baseUrl + "=w200-h113")
                
                self.downloadImage(from: url!, completion: { (image) in
                    DispatchQueue.main.async(execute: {() -> Void in
                        self.itemsCache.setObject(image!, forKey: NSString.init(string: item.id))
                        cell.displayContent(image: image!)
                    })
                })
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat
        var height: CGFloat

        let screenWidth = UIScreen.main.bounds.width
        
        width = (screenWidth - 30) / 2
        height = width * 9 / 16

        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if (offsetY > contentHeight - scrollView.frame.size.height && isLoadingContent == false && self.itemsStore.nextPageToken != nil) {
            isLoadingContent = true
            let loadingContentView = collectionView.supplementaryView(forElementKind: UICollectionElementKindSectionFooter, at: IndexPath(row: 0, section: 0))
            loadingContentView?.isHidden = false
            
            SharedAPI.getAlbum(albumId: self.albumStore.id, nextToken: self.itemsStore.nextPageToken) { (albumItems) in
                self.itemsStore.mediaItems += albumItems.mediaItems
                self.itemsStore.nextPageToken = albumItems.nextPageToken

                DispatchQueue.main.async(execute: {
                    self.collectionView.reloadData()
                    self.isLoadingContent = false
                    loadingContentView?.isHidden = true
                })
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = itemsStore.mediaItems[indexPath.row]
        
        self.selectedItem = item
        
        self.performSegue(withIdentifier: "itemSegue", sender: self)
    }
}

