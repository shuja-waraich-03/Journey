//
//  JournalCard.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI

struct JournalCard: View {
  let journal: Journal
  let onTap: () -> Void

  @State private var isPressed = false

  init(journal: Journal, onTap: @escaping () -> Void = {}) {
    self.journal = journal
    self.onTap = onTap
  }

  var body: some View {
    ZStack(alignment: .bottomLeading) {
      /* background image layer */
      Group {
        if let imageString = journal.thumbnailImage {
          /* check if it's a url or local file */
          if imageString.hasPrefix("http://") || imageString.hasPrefix("https://") {
            /* remote url - use asyncimage */
            AsyncImage(url: URL(string: imageString)) { phase in
              switch phase {
              case .empty:
                /* loading state */
                Color(.systemGray5)
                  .overlay(
                    ProgressView()
                      .tint(.white)
                  )
              case .success(let image):
                /* successfully loaded image */
                image
                  .resizable()
                  .scaledToFill()
              case .failure:
                /* failed to load - show placeholder */
                Color(.systemGray5)
                  .overlay(
                    Image(systemName: "photo.fill")
                      .font(.system(size: 40))
                      .foregroundColor(.white.opacity(0.5))
                  )
              @unknown default:
                Color(.systemGray5)
              }
            }
          } else {
            /* local file - load from ImageManager */
            if let uiImage = ImageManager.shared.loadImage(filename: imageString) {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
            } else {
              /* fallback if image not found */
              Color(.systemGray5)
                .overlay(
                  Image(systemName: "photo.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.5))
                )
            }
          }
        } else {
          /* placeholder background */
          LinearGradient(
            colors: [Color(.systemGray5), Color(.systemGray6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
          .overlay(
            Image(systemName: "photo")
              .font(.system(size: 100))
              .foregroundColor(.secondary.opacity(0.3))
          )
        }
      }
      .frame(maxHeight: 200)
      .clipped()

      /* gradient overlay for text readability */
      LinearGradient(
        colors: [Color.clear, Color.black.opacity(0.7)],
        startPoint: .top,
        endPoint: .bottom
      )

      /* text content overlay */
      VStack(alignment: .leading, spacing: 6) {
        Text(journal.title ?? "Untitled")
          .font(.system(size: AppFontSize.headerMedium))
          .fontWeight(.bold)
          .foregroundColor(.white)
          .lineLimit(1)
        /* calendar and location details*/
        HStack(spacing: 12) {
          /* render journal date */
          HStack(spacing: 4) {
            Image(systemName: "calendar")
              .font(.system(size: 13))
            Text(journal.createdAt, style: .date)
              .font(.system(size: 13))
          }
          /* render journal location if applicable */
          if let location = journal.location {
            HStack(spacing: 4) {
              Image(systemName: "location.fill")
                .font(.system(size: 13))
              Text(location)
                .font(.system(size: 13))
                .lineLimit(1)
            }
          }
        }
        .foregroundColor(.white.opacity(0.9))

        Text(journal.snippet)
          .font(.system(size: 14))
          .foregroundColor(.white.opacity(0.95))
          .lineLimit(2)
          .multilineTextAlignment(.leading)
      }
      .padding(AppSpacing.medium)
    }
    .frame(height: 200)
    .frame(maxWidth: .infinity)
    .clipShape(RoundedRectangle(cornerRadius: 16))
    .contentShape(RoundedRectangle(cornerRadius: 16))
    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    .scaleEffect(isPressed ? 0.9 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    .onTapGesture {
      isPressed = true
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isPressed = false
        onTap()
      }
    }
  }
}

#Preview {
  VStack(spacing: AppSpacing.medium) {
    /* card without image */
    JournalCard(journal: {
      var journal = Journal()
      journal.title = "My Trip to Paris"
      journal.createdAt = Date()
      journal.location = "Paris, France"
      journal.content = "Today was an amazing day exploring the Eiffel Tower and enjoying French cuisine. The weather was perfect and I met some wonderful people along the way."
      return journal
    }(), onTap: {
      print("Card tapped: My Trip to Paris")
    })
    /* card with image */
    JournalCard(journal: {
      var journal = Journal()
      journal.title = "Morning Reflections"
      journal.createdAt = Date().addingTimeInterval(-86400)
      journal.location = "San Francisco, CA"
      journal.content = "Woke up early today and spent some time thinking about my goals for this year. I want to focus on personal growth and building meaningful connections."
      journal.images = ["https://i.imgur.com/IdorGF4.png"]
      return journal
    }(), onTap: {
      print("Card tapped: Morning Reflections")
    })
  }
  .padding()
}
