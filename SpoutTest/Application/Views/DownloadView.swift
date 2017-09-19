//
//  DownloadView.swift
//  SpoutTest
//
//  Created by Asquare on 9/19/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import Popover

class DownloadView: UIView {
    var titleLabel: UILabel
    var subtitleLabel: UILabel
    var cancelButton: UIButton
    var videoModel: VideoModel?
    var request: DataRequest?
    var popover: Popover?

    
    //MARK: - Init
    override private init(frame: CGRect) {
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        cancelButton = UIButton()
        super.init(frame: frame)
    }
    
    convenience init(frame: CGRect, model: VideoModel) {
        self.init(frame: frame)
        videoModel = model
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Setup views
    func setupViews() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.text = "Downloading \(videoModel?.name ?? "Video")"
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .body)
        subtitleLabel.text = " 0 % "
        subtitleLabel.textAlignment = .center
        addSubview(subtitleLabel)
        
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.setTitleColor(UIColor.black, for: .normal)
        cancelButton.layer.borderColor = UIColor.black.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 5
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        addSubview(cancelButton)
        
        updateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        let offset: CGFloat = 10
        
        subtitleLabel.snp.updateConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.right.equalTo(titleLabel)
            make.center.equalTo(self)
            make.height.equalTo(subtitleLabel.intrinsicContentSize)
        }
        
        titleLabel.snp.updateConstraints { (make) in
            make.top.equalTo(self).offset(offset)
            make.left.equalTo(self).offset(offset)
            make.right.equalTo(self).offset(-offset)
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-offset)
            
        }
        
        cancelButton.snp.updateConstraints { (make) in
            make.bottom.equalTo(self).offset(-offset)
            make.width.equalTo(100)
            make.height.equalTo(40).priority(250)
            make.top.greaterThanOrEqualTo(subtitleLabel.snp.bottom).offset(offset)
            make.centerX.equalTo(self)
        }
    }
    
    
    //MARK: - Methods
    func didTapCancelButton() {
        request?.cancel()
        popover?.dismiss()
    }
    
    func startDownloadingVideo() {
        guard let offlineUrl = videoModel?.offlineUrl else {
            subtitleLabel.text = "This video does not have offline url!"
            return
        }
        
        let progressBlock: (Progress)->Void = { [weak self] progress in
            let format = NumberFormatter()
            format.numberStyle = .decimal
            format.maximumFractionDigits = 2
            let number = format.number(from: "\(progress.fractionCompleted*100)")
            let stringNumber = format.string(from: number ?? 0) ?? "0"
            self?.subtitleLabel.text =  "\(stringNumber) %"
        }
        
        let completionBlock: (DataResult)->Void = { [weak self] result in
            switch result {
            case .success(let data):
                self?.subtitleLabel.text = "Complete downloading video. \n Saving to local file"
                self?.save(video: data)
            case .failure(let errorMessage):
                self?.subtitleLabel.text = "Error download video: \(errorMessage)"
            }
            
        }
        
        request = ServiceManager.shared.downloadVideo(from: offlineUrl,
                                                      downloadingProgress: progressBlock,
                                                      completion: completionBlock)
        
    }
    
    func save(video data: Data) {
        guard let id = videoModel?.id else {
            subtitleLabel.text = "Error saving video, model does not have ID!"
            return
        }
        
        let fileURL = try? FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   create: false).appendingPathComponent("\(id).mp4")
        guard let url = fileURL else {
            subtitleLabel.text = "Error saving video, cannot get file path!"
            return
        }
        
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            print(error)
            subtitleLabel.text = "Error saving video, cannot write to file path!"
            return
        }
        
        var savedVideos = [Int]()
        if let localSavedVideos = UserDefaults.standard.object(forKey: kSavedVideos) as? [Int] {
            savedVideos = localSavedVideos
        }
        
        savedVideos.append(id)
        UserDefaults.standard.set(savedVideos, forKey: kSavedVideos)
        UserDefaults.standard.synchronize()
        subtitleLabel.text = "Video is saved!"
    }
    
}
