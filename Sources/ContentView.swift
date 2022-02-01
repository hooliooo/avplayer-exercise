//
//  ContentView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import AVFoundation
import AVKit
import OSLog
import SwiftUI

internal let ViewLog: OSLog = OSLog(subsystem: "com.alorro.AVPlayerExercise", category: "UI")

struct ContentView: View {

    let url: URL = URL(
        string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"
    )! // swiftlint:disable:this force_unwrapping

    @State var isPlaying: Bool = false
    @State var showControls: Bool = true
    @State var workItem: DispatchWorkItem?

    var body: some View {
        ZStack(alignment: .bottom) {
            VideoPlayerView(url: self.url, mode: isPlaying ? .play : .pause)

            if self.showControls {
                Text(self.isPlaying ? "Pause" : "Play")
                    .frame(width: 150.0, height: 66.0, alignment: .center)
                    .foregroundColor(Color.white)
                    .background(Color.red)
                    .onTapGesture {
                        self.isPlaying.toggle()
                        self.workItem?.cancel()
                        self.onGestureEnd()
                    }
                    .transition(.scale)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0.0)
                .onChanged { _ in
                    os_log("Dragging Currently", log: ViewLog, type: OSLogType.info)
                    self.workItem?.cancel()
                    withAnimation {
                        self.showControls = true
                    }
                }
                .onEnded { _ in
                    os_log("Dragging Ended", log: ViewLog, type: OSLogType.info)
                    self.onGestureEnd()
                }
        )
    }

    private func onGestureEnd() {
        let item: DispatchWorkItem = DispatchWorkItem {
            withAnimation {
                self.showControls = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: item)
        self.workItem = item
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
