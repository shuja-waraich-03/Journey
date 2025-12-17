//
//  AppHeader.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI

enum HeaderPaddingStyle {
  case both
  case bottom
  case none
}

struct AppHeader: View {
  let text: String
  let showIcon: Bool
  let paddingStyle: HeaderPaddingStyle
  let trailingButton: (() -> AnyView)?

  init(text: String, showIcon: Bool = false, paddingStyle: HeaderPaddingStyle = .both, trailingButton: (() -> AnyView)? = nil) {
    self.text = text
    self.showIcon = showIcon
    self.paddingStyle = paddingStyle
    self.trailingButton = trailingButton
  }

  var body: some View {
    HStack(spacing: AppSpacing.small) {
      Spacer()
      AppTitle(text: text, showIcon: showIcon)
      Spacer()
    }
    .overlay(alignment: .trailing) {
      if let trailingButton = trailingButton {
        trailingButton()
          .padding(.trailing, AppSpacing.medium)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.top, paddingStyle == .both ? AppSpacing.headerPaddingVertical : 0)
    .padding(.bottom, paddingStyle != .none ? AppSpacing.headerPaddingVertical : 0)
    .background(AppGradients.primary)
  }
}

#Preview {
  AppHeader(text: "Journey", showIcon: true)
}
