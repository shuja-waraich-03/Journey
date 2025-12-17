//
//  GradientButton.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI

struct GradientButton: View {
  let text: String
  let icon: String?
  let fullWidth: Bool
  let action: () -> Void

  init(text: String, icon: String? = nil, fullWidth: Bool = false, action: @escaping () -> Void) {
    self.text = text
    self.icon = icon
    self.fullWidth = fullWidth
    self.action = action
  }

  var body: some View {
    Button(action: action) {
      HStack {
        if let icon = icon {
          Image(systemName: icon)
            .font(.system(size: 20))
        }
        Text(text)
          .fontWeight(.semibold)
      }
      .frame(maxWidth: fullWidth ? .infinity : nil)
      .foregroundColor(.white)
      .padding(AppSpacing.small)
      .background(AppGradients.primary)
      .cornerRadius(10)
    }
  }
}

#Preview {
  VStack {
    GradientButton(text: "Create New Journal", icon: "plus", action: {
      print("Button with icon tapped")
    })

    GradientButton(text: "Save Changes", action: {
      print("Button without icon tapped")
    })
  }
}
