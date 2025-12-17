//
//  LaunchScreenView.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

/**
 * LaunchScreenView - Splash screen shown when app launches
 *
 * This view displays briefly when the app first opens, showing the app icon
 * and name with a gradient background matching the app's theme.
 *
 */

import SwiftUI

struct LaunchScreenView: View {
  /* controls whether to show splash screen or main app */
  @State private var isActive = false

  /* controls fade-in animation */
  @State private var opacity = 0.0

  var body: some View {
    if isActive {
      /* show main app after splash screen */
      DashboardView()
    } else {
      /* splash screen */
      ZStack {
        /* gradient background matching app theme */
        AppGradients.primary
          .ignoresSafeArea()
        VStack(spacing: 0) {
          /* app icon */
          Image("favicon")
            .resizable()
            .scaledToFit()
            .frame(width: 120)
          /* app name */
          Text("Journey")
            .font(AppFonts.headerXXlarge)
            .foregroundColor(.white)
        }
        .opacity(opacity) /* fade-in animation */
      }
      .onAppear {
        /* animate fade-in */
        withAnimation(.easeIn(duration: 1.0)) {
          opacity = 1.0
        }
        /* transition to main app after 1.5 seconds */
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
          withAnimation {
            isActive = true
          }
        }
      }
    }
  }
}

#Preview {
  LaunchScreenView()
}
