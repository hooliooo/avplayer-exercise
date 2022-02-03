//
//  View+AVPlayerExercise.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 03.02.22.
//

import SwiftUI

public extension View {

    func playbackStyling(size: CGSize, cornerRadius: CGFloat) -> some View {
        return self
            .frame(width: size.width, height: size.height, alignment: .center)
            .foregroundColor(Color.white)
            .background(Color.red)
            .cornerRadius(cornerRadius)
            .transition(.scale)
    }

}
