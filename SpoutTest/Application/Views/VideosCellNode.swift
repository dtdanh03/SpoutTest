//
//  VideosCellNode.swift
//  SpoutTest
//
//  Created by Asquare on 9/18/17.
//  Copyright © 2017 Company. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class VideosCellNode: ASCellNode {
    var backgroundImage: ASNetworkImageNode
    var blurNode: ASDisplayNode
    var videoName: ASTextNode
    
    let nameAttributes = [NSForegroundColorAttributeName: UIColor.white,
                          NSFontAttributeName: UIFont.preferredFont(forTextStyle: .headline)]
    
    init(model: VideoModel) {
        backgroundImage = ASNetworkImageNode()
        blurNode = ASDisplayNode()
        videoName = ASTextNode()
        super.init()
        automaticallyManagesSubnodes = true
        
        backgroundImage.url = URL(string: model.backgroundImage ?? "")
        videoName.attributedText = NSAttributedString(string: model.name ?? "", attributes: nameAttributes)
        blurNode.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let ratioForImage = ASRatioLayoutSpec(ratio: 0.5, child: backgroundImage)
        
        let centerForText = ASCenterLayoutSpec()
        centerForText.centeringOptions = .XY
        centerForText.child = videoName
        
        let overlayText = ASOverlayLayoutSpec(child: blurNode, overlay: centerForText)
        let insetForBlurNode = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(CGFloat.infinity, 0, 0, 0), child: overlayText)
        blurNode.style.height = ASDimensionMake("15%")
        let overlayForImage = ASOverlayLayoutSpec(child: ratioForImage, overlay: insetForBlurNode)
        return overlayForImage
    }
}
