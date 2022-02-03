//
//  PlaybackProgressView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 02.02.22.
//

import ComposableArchitecture
import SwiftUI

public struct PlaybackProgressView: View {

    // MARK: Stored Properies
    @Binding public var currentProgress: TimeInterval
    @Binding public var seekProgress: TimeInterval?
    public let end: TimeInterval
    private let height: CGFloat = 7.5
    private let insets: EdgeInsets = EdgeInsets(top: 10.0, leading: 15.0, bottom: 0.0, trailing: 15.0)

    private var percentage: CGFloat {
        if self.end > 0.0 {
            return CGFloat(self.currentProgress / self.end)
        } else {
            return 0.0
        }

    }

    public var body: some View {
        VStack(alignment: .center, spacing: 15.0) {
            GeometryReader { (proxy: GeometryProxy) in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(
                            minWidth: 0.0,
                            maxWidth: .infinity,
                            minHeight: self.height,
                            maxHeight: self.height
                        )
                        .opacity(0.3)
                        .foregroundColor(Color(UIColor.systemBlue))

                    Rectangle()
                        .frame(
                            width: min(self.percentage * proxy.size.width, proxy.size.width),
                            height: self.height
                        )
                        .foregroundColor(Color(UIColor.systemBlue))
                    Circle()
                        .frame(width: 15.0, height: 15.0, alignment: Alignment.center)
                        .foregroundColor(Color.white)
                        .offset(x: min(self.percentage * proxy.size.width, proxy.size.width))
                }
                .gesture(
                    DragGesture(minimumDistance: 0.0)
                        .onChanged { (drag: DragGesture.Value) -> Void in
                            let percentage: CGFloat = min(max(0.0, drag.location.x / proxy.size.width), 1.0)
                            self.seekProgress = self.end * percentage
                        }
                        .onEnded { (_: DragGesture.Value) -> Void in
                            self.seekProgress = nil
                        }
                )
                .cornerRadius(45.0)
            }
            .padding(self.insets)
            HStack {
                let currentProgress: String = Constants.formatter.string(from: self.currentProgress) ?? "0:00"
                let remainingProgress: String = Constants.formatter.string(from: self.end - self.currentProgress) ?? "0:00"
                Text(currentProgress).font(.caption).padding(.leading, 15.0)
                Spacer()
                Text(remainingProgress).font(.caption).padding(.trailing, 15.0)
            }
        }
    }
}
