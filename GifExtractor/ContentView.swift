//
//  ContentView.swift
//  GifExtractor
//
//  Created by Hite on 2023/6/25.
//

import GifProvider
import SwiftUI
import UIKit

struct ContentView: View {
    @State var urlString: String = ""
    @State var speed: Float = 0
    @State private var isEditing = false
    
    @State private var playing = true
    @ObservedObject var gifLoader = GIFLoader()
    
    func loadImages() {
        Task {
            await gifLoader.load(url: self.urlString)
        }
    }
    
    func getName(_ url: String) -> String {
        let pathPart = self.urlString.components(separatedBy: "?")[0]
        return pathPart.components(separatedBy: "/").last ?? "unknown"
    }
    
    var body: some View {
        let imageName = getName(self.urlString)

        let images = gifLoader.images
        let imageCount = images.count
        
        var keyFrame: UIImage?
        var width = 0, height = 0
        let idx = Int(self.speed)
        if idx < imageCount {
            keyFrame = images[idx]
            width = keyFrame?.cgImage?.width ?? 0
            height = keyFrame?.cgImage?.height ?? 0
            
            print("Image size = (\(width), \(height))")
        }
        let icons = GifProvider.Loader.instance.getImages()
        
        return Form {
            if let icon = icons.last {
                HStack {
                    Image(uiImage: icon)
                    Text("Play Gifs or view frames")
                }
            }
            Section {
                TextField("Input url here", text: $urlString) {
                    self.loadImages()
                }
                Button {
                    if let path = Bundle.main.path(forResource: "enjoy_fighting", ofType: "gif") {
                        self.urlString = path
                        self.loadImages()
                    }
                } label: {
                    Text("Load default GIF")
                }

            } header: {
                Text("Set the url of gif image:")
            }
            
            Text("Now playing: \(imageName)")
            
            HStack {
                if !self.playing && imageCount > 0 {
                    Image(uiImage: keyFrame!).onTapGesture {
                        self.playing = true
                    }
                } else {
                    GIFImageView(playing: $playing, images: images)
                }
            }.frame(maxWidth: .infinity)

            Text(
                """
                The total of frames in gif is \(Text("\(imageCount)").foregroundColor(.red))
                """)
    
            Section {
                Slider(
                    value: $speed,
                    in: 0 ... Float(max(1, imageCount - 1)),
                    step: 1.0
                ) {
                    Text("The index of frame")
                } minimumValueLabel: {
                    Text("0")
                } maximumValueLabel: {
                    Text("\(imageCount)")
                } onEditingChanged: { editing in
                    isEditing = editing
                    self.playing = false
                }.disabled(imageCount < 1)
                
                Text("Show the \(Text("\(Int(speed))").foregroundColor(.red)) th image of playing gif")
                    .foregroundColor(isEditing ? .blue : .black)
            } header: {
                Text("extract a frame")
            }
        }.onAppear {
            print(UIApplication.shared.keyWindow?.value(forKey: "recursiveDescription")!
)
        }
    }
}

 #Preview {
    ContentView()
 }
