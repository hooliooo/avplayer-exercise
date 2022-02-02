//
//  VideoOptionView.swift
//  AVPlayerExercise
//
//  Created by Julio Alorro on 01.02.22.
//

import SwiftUI

public struct VideoOptionView: View {

    public let name: String
    public let isSelected: Bool

    public var body: some View {
        HStack {
            if self.isSelected {
                Image(systemName: "checkmark")
            }
            Text(self.name)
        }
    }
}
//
//struct VideoOption_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoOptionView(name: "Hello, World", isSelected: false)
//    }
//}
