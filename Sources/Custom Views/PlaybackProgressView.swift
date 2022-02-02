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
    @Binding public var progress: TimeInterval
    public let end: TimeInterval
    private let height: CGFloat = 7.5

    public var body: some View {
        VStack(alignment: .center) {
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
                        width: 20.0,
                        height: self.height
                    )
                    .foregroundColor(Color(UIColor.systemBlue))
            }
                .cornerRadius(45.0)
            HStack {
                let currentProgress: String = Constants.formatter.string(from: self.progress) ?? "0:00"
                let remainingProgress: String = Constants.formatter.string(from: self.end - self.progress) ?? "0:00"
                Text(currentProgress).font(.caption)
                Spacer()
                Text(remainingProgress).font(.caption)
            }
        }
            .padding(EdgeInsets(top: 0.0, leading: 15.0, bottom: 0.0, trailing: 15.0))
    }
}
