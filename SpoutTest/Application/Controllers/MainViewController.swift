//
//  MainViewController.swift
//  SpoutTest
//
//  Created by Asquare on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import AVKit

class MainViewController: ASViewController<ASCollectionNode> {
    
    //MARK: - Properties
    var videos = [VideoModel]()
    
    //MARK: - Init
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        super.init(node: ASCollectionNode(collectionViewLayout: layout))
        node.delegate = self
        node.dataSource = self
        node.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Videos"
        loadData()
    }
    
    //MARK: - Methods
    func loadData() {
        ServiceManager.shared.getData(from: "https://s3-ap-southeast-1.amazonaws.com/spout360/data.json") { (result) in
            switch result {
            case .success(let videos):
                self.videos = videos
                self.node.reloadData()
            case .failure(let errorMessage):
                print(errorMessage)
            }
        }
    }
    
}


//MARK: - CollectionDataSource
extension MainViewController: ASCollectionDataSource {
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        let videoModel = videos[indexPath.item]
        return {
            return VideosCellNode(model: videoModel)
        }
    }
}

//MARK: - CollectionDelegate
extension MainViewController: ASCollectionDelegate {
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        let video = videos[indexPath.item]
        guard let streamUrlString = video.streamUrl,
            let offlineUrlString = video.offlineUrl,
            let streamUrl = URL(string: streamUrlString),
            let offlineUrl = URL(string: offlineUrlString) else {
                return
        }

        let player = AVPlayer(url: streamUrl)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
}
