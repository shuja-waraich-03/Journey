//
//  AppTitle.swift
//  Journey
//
//  Created by Camposm on 11/18/25.
//

import SwiftUI

struct AppTitle: View {
  let text: String;
  let showIcon: Bool
  
  init(text: String, showIcon: Bool = false) {
    self.text = text
    self.showIcon = showIcon
  }
  
  var body: some View {
    HStack(spacing: AppSpacing.small) {
      if showIcon {
        Image("favicon")
          .resizable()
          .scaledToFit()
          .frame(width: 40, height: 40)
//          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      Text("\(text)")
        .font(AppFonts.headerLarge)
        .foregroundColor(.white)
    }
  }
}

#Preview {
  VStack {
    AppTitle(text: "Journey", showIcon: true)
  }
  .background(AppGradients.primary)
  .frame(width: .infinity, height: .infinity)
}
