//
//  GIfLoader.swift
//  GifExtractor
//
//  Created by Hite on 2023/6/25.
//

import Foundation

import UIKit
import Combine

public class GIFLoader: ObservableObject {
    public init() {}
    
    @Published var images = [UIImage]()
    
    // async 的 function 会在 Thread 16 Queue : com.apple.root.user-initiated-qos.cooperative (concurrent)
    // 这样的队列里执行
    public func load(url: String) async {
        var gifURL: URL?
        if url.starts(with: "http://") || url.starts(with: "https://") {
            gifURL = URL(string: url)
        } else {
            gifURL = URL(fileURLWithPath: url)
        }
        
        if let gifURL = gifURL {
            var images2 = [UIImage]()
            if let source = CGImageSourceCreateWithURL(gifURL as CFURL, nil) {
               let imageCount = CGImageSourceGetCount(source)
               
               print("URL:\(gifURL) contains \(imageCount) images.")
               for i in 0 ..< imageCount {
                   if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                       images2.append(UIImage(cgImage: image))
                   }
               }
            }
            
            // 下载逻辑 cocurrently-executed，published 逻辑在 mainActor
            await MainActor.run {[images2] in
                self.images = images2
            }
        } else {
            print("URL:\(url) is invalid, keep old images")
        }
    }

}
