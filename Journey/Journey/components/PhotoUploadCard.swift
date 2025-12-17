//
//  PhotoUploadCard.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI
import PhotosUI

/**
 * PhotoUploadCard - A reusable component for selecting and displaying photos
 *
 * This component uses PhotosPicker to let users select images from
 * their photo library. It displays a placeholder when no image is selected,
 * and shows the selected image once chosen.
 *
 * Usage in a parent view:
 *   @State private var imageData: Data?
 *   @State private var selectedImage: PhotosPickerItem?
 *   PhotoUploadCard(imageData: $imageData, selectedImage: $selectedImage)
 *
 */
struct PhotoUploadCard: View {
  /* binding to parent view's image data (the actual image bytes) */
  @Binding var imageData: Data?

  /* binding to parent view's selected photo picker item */
  @Binding var selectedImage: PhotosPickerItem?

  var body: some View {
    /* PhotosPicker provides the photo selection UI */
    PhotosPicker(selection: $selectedImage, matching: .images) {
      ZStack {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
          /* if we have image data, convert it to UIImage and display it */
          Image(uiImage: uiImage)
            .resizable() /* allows image to be resized */
            .scaledToFill() /* fills the frame, cropping if needed */
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(
                  LinearGradient(
                    colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ),
                  lineWidth: 3
                )
            )
        } else {
          /* show placeholder when no image is selected */
          RoundedRectangle(cornerRadius: 16)
            .fill(
              LinearGradient(
                colors: [AppColors.primaryGradientStart.opacity(0.1), AppColors.primaryGradientEnd.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .overlay(
              VStack(spacing: 12) {
                Image(systemName: "photo.badge.plus") /* SF Symbol icon */
                  .font(.system(size: 50))
                  .foregroundColor(AppColors.primaryGradientStart)
                Text("Tap to add photo")
                  .font(.system(size: AppFontSize.body))
                  .foregroundColor(.primary)
              }
            )
            .overlay(
              RoundedRectangle(cornerRadius: 16)
                .stroke(
                  LinearGradient(
                    colors: [AppColors.primaryGradientStart.opacity(0.3), AppColors.primaryGradientEnd.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  ),
                  lineWidth: 2
                )
            )
        }
      }
      .padding(.horizontal, AppSpacing.medium)
    }
    /**
     * onChange monitors selectedImage for changes
     *
     * When the user selects a photo from PhotosPicker, selectedImage updates.
     * This triggers the onChange handler, which loads the actual image data.
     */
    .onChange(of: selectedImage) { oldValue, newValue in
      Task {
        /* asynchronously load the image data from the selected photo */
        if let data = try? await newValue?.loadTransferable(type: Data.self) {
          imageData = data /* update the binding, which updates parent view */
        }
      }
    }
  }
}
