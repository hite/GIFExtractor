//
//  GIFImageView.swift
//  GifExtractor
//
//  Created by Hite on 2023/6/26.
//

import Foundation
import SwiftUI
import UIKit


class ActionCoordinator: NSObject {
    @Binding var playing: Bool
    
    init(playing: Binding<Bool>) {
        _playing = playing
    }
    
    @objc func play(_ sender: UIView) {
        self.playing = !self.playing
    }
}

struct GIFImageView: UIViewRepresentable {
    typealias UIViewType = UIImageView
    
    @Binding var playing: Bool
    var images: [UIImage]
    
    
    func makeUIView(context: Context) -> UIImageView {
        print("makeUIView")
  
        let uiView = UIImageView()
        uiView.isUserInteractionEnabled = true
        let coord = ActionCoordinator(playing: $playing)
        let tapGesture = UITapGestureRecognizer(target: coord, action: #selector(ActionCoordinator.play(_:)))
        uiView.addGestureRecognizer(tapGesture)
        
        uiView.contentMode = .scaleAspectFit
        
        return uiView
    }
    
    func updateUIView(_ uiView: UIImageView, context: Context) {
        print("UpdateView, images.count = \(images.count)")
        
        if self.playing {
            if let images = uiView.animationImages, images.count > 0 {
                uiView.stopAnimating()
            }
            
            uiView.animationImages = images
            uiView.animationDuration = TimeInterval(images.count / 10) // 一秒播放 10 帧吧
            
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
    
    // 关于 GIF 图片点击事件有两个地方可以处理，一个是使用 coordinator，一个是使用外面的 onTap 事件 + bind
}
