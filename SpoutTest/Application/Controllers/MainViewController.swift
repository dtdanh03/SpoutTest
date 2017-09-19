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
import Popover

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
    
    func showOptionsAction(at index: Int) {
        let actionSheet = UIAlertController(title: "Choose actions", message: "", preferredStyle: .actionSheet)
        
        let streamAction = UIAlertAction(title: "Live Stream", style: .default) { [weak self] (action) in
            self?.liveStreamVideo(at: index)
        }
        let downloadAction = UIAlertAction(title: "Download video", style: .default) { [weak self] (action) in
            self?.downloadVideo(at: index)
        }
        let playVideoOfflineAction = UIAlertAction(title: "Play video offline", style: .default) { [weak self] (action) in
            self?.playVideoOffline(at: index)
        }
        let deleteAction = UIAlertAction(title: "Delete offline video", style: .destructive) { [weak self] (action) in
            self?.deleteOfflineVideo(at: index)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheet.addAction(streamAction)
        if isVideoSaved(at: index) {
            actionSheet.addAction(playVideoOfflineAction)
            actionSheet.addAction(deleteAction)
        } else {
            actionSheet.addAction(downloadAction)
        }
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
        
    }
    
    func liveStreamVideo(at index: Int) {
        let video = videos[index]
        guard let stringUrl = video.streamUrl,
            let streamUrl = URL(string: stringUrl) else {
            return
        }
        playVideo(with: streamUrl)
    }

    
    func playVideo(with url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
    
    func downloadVideo(at index: Int) {
        let video = videos[index]
        let popover = Popover()
        popover.dismissOnBlackOverlayTap = false
        popover.arrowSize = CGSize.zero
        popover.cornerRadius = 10
        popover.blackOverlayColor = UIColor.black.withAlphaComponent(0.8)
        
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*3/4, height: 150)
        let downloadView = DownloadView(frame: rect, model: video)
        downloadView.popover = popover
        popover.showAsDialog(downloadView)
        downloadView.startDownloadingVideo()
    }
    
    func isVideoSaved(at index: Int) -> Bool {
        let video = videos[index]
        guard let id = video.id,
        let savedVideos = UserDefaults.standard.object(forKey: kSavedVideos) as? [Int] else {
            return false
        }
        return savedVideos.contains(id)
    }
    
    func playVideoOffline(at index: Int) {
        guard let localFileURL = getLocalFileURL(at: index) else {
            return
        }
        playVideo(with: localFileURL)
    }
    
    func deleteOfflineVideo(at index: Int) {
        guard let localFileURL = getLocalFileURL(at: index) else { return }
        guard let _ = try? FileManager.default.removeItem(at: localFileURL) else { return }
        guard var savedVideos =  UserDefaults.standard.object(forKey: kSavedVideos) as? [Int],
            let id = videos[index].id,
            let positionToRemove = savedVideos.index(of: id) else {
                return
        }
        savedVideos.remove(at: positionToRemove)
        UserDefaults.standard.set(savedVideos, forKey: kSavedVideos)
        UserDefaults.standard.synchronize()
    }
    
    func getLocalFileURL(at index: Int) -> URL? {
        let video = videos[index]
        guard let id = video.id else {
            return nil
        }
        
        let fileURL = try? FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false).appendingPathComponent("\(id).mp4")
        guard let localFileURL = fileURL else {
            return nil
        }
        print(localFileURL)
        return localFileURL
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
        showOptionsAction(at: indexPath.item)
    }
}
