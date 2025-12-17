//
//  JournalDetailView.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI

struct JournalDetailView: View {
  @Environment(\.dismiss) var dismiss
  let journal: Journal
  let onEdit: () -> Void
  let onDelete: () -> Void
  
  @State private var showDeleteAlert = false
  @State private var isReadingMode = false

  private var wordCount: Int {
    guard let content = journal.content else { return 0 }
    let words = content.components(separatedBy: .whitespacesAndNewlines)
    return words.filter { !$0.isEmpty }.count
  }

  private var characterCount: Int {
    return journal.content?.count ?? 0
  }

  private var readingTime: Int {
    /* average reading speed is 200-250 words per minute, using 225 */
    return max(1, Int(ceil(Double(wordCount) / 225.0)))
  }

  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          /* reading mode title (shown when hero is hidden) */
          if isReadingMode {
            VStack(alignment: .leading, spacing: AppSpacing.small) {
              Text(journal.title ?? "Untitled")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

              HStack(spacing: AppSpacing.medium) {
                HStack(spacing: 4) {
                  Image(systemName: "calendar")
                  Text(journal.createdAt, style: .date)
                }
                .font(.system(size: AppFontSize.caption))
                .foregroundColor(.secondary)
//                if let date = journal.createdAt {
//                  HStack(spacing: 4) {
//                    Image(systemName: "calendar")
//                    Text(date, style: .date)
//                  }
//                  .font(.system(size: AppFontSize.caption))
//                  .foregroundColor(.secondary)
//                }
                if let location = journal.location {
                  HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                    Text(location)
                  }
                  .font(.system(size: AppFontSize.caption))
                  .foregroundColor(.secondary)
                }
              }
            }
            .padding(.horizontal, AppSpacing.medium)
            .padding(.top, AppSpacing.medium)
            .padding(.bottom, AppSpacing.small)
          }

          /* hero image with title overlay - extends under toolbar */
          if !isReadingMode {
            ZStack(alignment: .bottomLeading) {
            /* background image */
            Group {
              if let imageString = journal.thumbnailImage {
                /* check if it's a url or local file */
                if imageString.hasPrefix("http://") || imageString.hasPrefix("https://") {
                  /* remote url */
                  AsyncImage(url: URL(string: imageString)) { phase in
                    switch phase {
                    case .success(let image):
                      image
                        .resizable()
                        .scaledToFill()
                    case .empty:
                      Color(.systemGray5)
                        .overlay(ProgressView())
                    case .failure:
                      Color(.systemGray5)
                        .overlay(
                          Image(systemName: "photo.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
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
                          .foregroundColor(.secondary)
                      )
                  }
                }
              } else {
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
            .frame(height: 280)
            .clipped()
            
            /* gradient overlay for text readability */
            LinearGradient(
              colors: [Color.clear, Color.black.opacity(0.7)],
              startPoint: .top,
              endPoint: .bottom
            )
            
            /* title and metadata overlay */
            VStack(alignment: .leading, spacing: AppSpacing.small) {
              Text(journal.title ?? "Untitled")
                .font(.system(size: AppFontSize.headerLarge, weight: .bold))
                .foregroundColor(.white)
              
              HStack(spacing: AppSpacing.medium) {
                HStack(spacing: 4) {
                  Image(systemName: "calendar")
                  Text(journal.createdAt, style: .date)
                }
                .font(.system(size: AppFontSize.caption))
                .foregroundColor(.white.opacity(0.9))
                
                if let location = journal.location {
                  HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                    Text(location)
                  }
                  .font(.system(size: AppFontSize.caption))
                  .foregroundColor(.white.opacity(0.9))
                }
              }
            }
            .padding(AppSpacing.medium)
            }
            .frame(maxWidth: .infinity)
          }

          VStack(alignment: .leading, spacing: AppSpacing.medium) {

            /* reading statistics */
            HStack(spacing: AppSpacing.large) {
              HStack(spacing: 4) {
                Image(systemName: "book")
                  .font(.system(size: 12))
                Text("\(readingTime) min read")
                  .font(.system(size: 13))
              }

              HStack(spacing: 4) {
                Image(systemName: "text.word.spacing")
                  .font(.system(size: 12))
                Text("\(wordCount) words")
                  .font(.system(size: 13))
              }

              HStack(spacing: 4) {
                Image(systemName: "character")
                  .font(.system(size: 12))
                Text("\(characterCount) chars")
                  .font(.system(size: 13))
              }
            }
            .foregroundColor(.secondary)
            .padding(.bottom, AppSpacing.small)

            /* content */
            if let content = journal.content {
              Text(content)
                .font(.system(size: isReadingMode ? 20 : AppFontSize.body))
                .lineSpacing(isReadingMode ? 8 : 4)
                .foregroundColor(.primary)
            }

            /* map view (hidden in reading mode) */
            if journal.location != nil && !isReadingMode {
              MapView(locationName: journal.location)
                .padding(.top, AppSpacing.small)
            }
          }
          .padding(.horizontal, AppSpacing.medium)
          .padding(.top, AppSpacing.large)
          .padding(.bottom, AppSpacing.medium)
        }
      }
      .ignoresSafeArea(edges: isReadingMode ? [] : .top)
      // .navigationBarTitleDisplayMode(.inline)
      .toolbar {
//        ToolbarItem(placement: .navigationBarLeading) {
//          Button(action: {
//            dismiss()
//          }) {
//            Image(systemName: "xmark.circle.fill")
//              .font(.system(size: 24))
//              .foregroundColor(.secondary)
//          }
//        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            withAnimation(.spring(response: 0.3)) {
              isReadingMode.toggle()
            }
          }) {
            Image(systemName: isReadingMode ? "book.fill" : "book")
              .font(.system(size: 18))
              .foregroundColor(.primary)
          }
        }

        if !isReadingMode {
          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              dismiss()
              onEdit()
            }) {
              Image(systemName: "pencil")
                .font(.system(size: 18))
                .foregroundColor(.primary)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 1)
            }
          }

          ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {
              showDeleteAlert = true
            }) {
              Image(systemName: "trash")
                .font(.system(size: 18))
                .foregroundColor(.red)
                .shadow(color: .black.opacity(0.5), radius: 3, x: 0, y: 1)
                .shadow(color: .white.opacity(0.5), radius: 3, x: 0, y: 1)
            }
          }
        }
      }
      .alert("Delete Journal", isPresented: $showDeleteAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Delete", role: .destructive) {
          dismiss()
          onDelete()
        }
      } message: {
        Text("Are you sure you want to delete this journal? This action cannot be undone.")
      }
    }
    .navigationViewStyle(.stack)
  }
}
