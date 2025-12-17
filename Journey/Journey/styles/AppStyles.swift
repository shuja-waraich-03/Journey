//
//  AppStyles.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

/**
 * AppStyles - Centralized Design System
 *
 * This file contains all the reusable styling constants for the app.
 * Instead of hardcoding values like ".font(.system(size: 32))" throughout
 * your views, you reference these constants for consistency.
 *
 * Common Design Systems:
 * - Material Design (Google): https://material.io/design
 * - Human Interface Guidelines (Apple): https://developer.apple.com/design
 * - Tailwind CSS (Web): https://tailwindcss.com
 *
 * Usage Examples:
 *   Text("Hello").font(.system(size: AppFontSize.headerLarge))
 *   VStack(spacing: AppSpacing.medium) { ... }
 *   .background(AppGradients.primary)
 */

import SwiftUI

/* MARK: - Custom Fonts */

struct AppFonts {
  /* custom font name - replace with your font file name without extension */
  static let customFontName = "IndieFlower"
  
  /* helper function to get custom font with fallback to system font */
  static func custom(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
    if let _ = UIFont(name: customFontName, size: size) {
      print("✅ Custom font '\(customFontName)' loaded successfully")
      return .custom(customFontName, size: size)
    }
    print("❌ Custom font '\(customFontName)' not found, using system font")
    print("Available fonts:")
    for family in UIFont.familyNames.sorted() {
      let fonts = UIFont.fontNames(forFamilyName: family)
      if !fonts.isEmpty {
        print("  \(family): \(fonts.joined(separator: ", "))")
      }
    }
    return .system(size: size, weight: weight)
  }
  
  /* predefined fonts for common use cases */
  static let headerXXlarge = custom(AppFontSize.headerXXlarge, weight: .bold)
  static let headerXlarge = custom(AppFontSize.headerXlarge, weight: .bold)
  static let headerLarge = custom(AppFontSize.headerLarge, weight: .bold)
  static let headerMedium = custom(AppFontSize.headerMedium, weight: .bold)
  static let headerSmall = custom(AppFontSize.headerSmall, weight: .semibold)
  static let body = Font.system(size: AppFontSize.body, weight: .regular)
  static let caption = Font.system(size: AppFontSize.caption, weight: .regular)
}

/* MARK: - Font Sizes */
struct AppFontSize {
  static let headerXXlarge: CGFloat = 48
  static let headerXlarge: CGFloat = 40
  static let headerLarge: CGFloat = 32
  static let headerMedium: CGFloat = 24
  static let headerSmall: CGFloat = 20
  static let body: CGFloat = 16
  static let caption: CGFloat = 14
}

/**
 * MARK: - Spacing (Padding/Margins)
 *
 * Defines consistent spacing values for padding, margins, and gaps.
 * Using multiples of 8 (8, 16, 24, 32) is a common design practice
 * for visual harmony and alignment.
 *
 * Spacing Guide:
 * - small (8): Tight spacing within components
 * - medium (16): Standard spacing between elements
 * - large (24): Generous spacing between sections
 * - extraLarge (32): Maximum spacing for major sections
 */
struct AppSpacing {
  static let headerPaddingVertical: CGFloat = 16
  static let small: CGFloat = 8
  static let medium: CGFloat = 16
  static let large: CGFloat = 24
  static let extraLarge: CGFloat = 32
}

/**
 * MARK: - Colors
 *
 * Defines the color palette for the app.
 * Centralizing colors allows for easy theme changes (dark mode, brand updates).
 *
 * Color Theory for Students:
 * - Primary colors: Main brand colors (buttons, headers)
 * - Secondary colors: Accent colors (highlights, badges)
 * - Neutral colors: Backgrounds, borders, text (grays, blacks, whites)
 *
 * SwiftUI Color types:
 * - Color.blue: Static SwiftUI color
 * - Color(red: 0.5, green: 0.5, blue: 1.0): Custom RGB
 * - Color(.systemGray6): System colors that adapt to light/dark mode
 */
struct AppColors {
  static let primaryGradientStart = Color.blue
  static let primaryGradientEnd = Color.purple
}

/**
 * MARK: - Gradients
 *
 * Defines reusable gradient styles.
 * LinearGradient creates a smooth color transition between two or more colors.
 *
 * Gradient Properties:
 * - colors: Array of colors to transition between
 * - startPoint: Where gradient begins (.topLeading = top-left corner)
 * - endPoint: Where gradient ends (.bottomTrailing = bottom-right corner)
 *
 * Common Gradient Patterns:
 * - Diagonal: .topLeading to .bottomTrailing
 * - Vertical: .top to .bottom
 * - Horizontal: .leading to .trailing
 */
struct AppGradients {
  static let primary = LinearGradient(
    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
}

/**
 * MARK: - View Modifiers
 *
 * ViewModifier is a reusable way to apply multiple styling changes at once.
 * Instead of repeating the same modifiers, create a ViewModifier and apply it.
 *
 * Example without ViewModifier (repetitive):
 *   Text("Title").font(.system(size: 32)).bold().foregroundColor(.white).padding(.bottom, 16)
 *   Text("Header").font(.system(size: 32)).bold().foregroundColor(.white).padding(.bottom, 16)
 *
 * Example with ViewModifier (cleaner):
 *   Text("Title").headerStyle()
 *   Text("Header").headerStyle()
 */
struct HeaderStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(AppFonts.headerLarge)
      .foregroundColor(.white)
      .padding(.bottom, AppSpacing.headerPaddingVertical)
  }
}

/**
 * MARK: - Card Input Style
 *
 * ViewModifier for text inputs with card-based design:
 * - White background with subtle shadow
 * - Rounded corners (12pt)
 * - Thin border for definition
 *
 * Usage:
 *   TextField("Name", text: $name)
 *     .padding(AppSpacing.small)
 *     .cardInputStyle()
 */
struct CardInputStyle: ViewModifier {
  var isError: Bool = false

  func body(content: Content) -> some View {
    content
      .background(
        RoundedRectangle(cornerRadius: 8)
          .fill(Color(.systemBackground))
          .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(
            isError ? Color.red : Color(.systemGray4),
            lineWidth: isError ? 2 : 1
          )
      )
  }
}

/**
 * Extension to View for convenient access to custom modifiers
 *
 * This allows you to call .headerStyle() on any SwiftUI view:
 *   Text("Journey").headerStyle()
 *
 * Instead of:
 *   Text("Journey").modifier(HeaderStyle())
 */
extension View {
  func headerStyle() -> some View {
    modifier(HeaderStyle())
  }

  /// Applies card input styling with optional error state
  /// - Parameter isError: Whether to show error styling (red border)
  func cardInputStyle(isError: Bool = false) -> some View {
    modifier(CardInputStyle(isError: isError))
  }
}
