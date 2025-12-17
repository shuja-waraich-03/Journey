import SwiftUI
import PhotosUI

struct ProfileView: View {
  // Initial values and callbacks
  let onSave: (String, String, String, UIImage?) -> Void
  let onCancel: () -> Void

  private let initialName: String
  private let initialEmail: String
  private let initialBio: String
  private let initialImage: UIImage?

  // Editable state
  @State private var name: String
  @State private var email: String
  @State private var bio: String

  @State private var selectedItem: PhotosPickerItem? = nil
  @State private var image: UIImage? = nil

  @Environment(\.dismiss) private var dismiss

  private let profileManager = ProfileDataManager.shared
  
  init(initialName: String = "",
       initialEmail: String = "",
       initialBio: String = "",
       initialImage: UIImage? = nil,
       onSave: @escaping (String, String, String, UIImage?) -> Void,
       onCancel: @escaping () -> Void) {
    self._name = State(initialValue: initialName)
    self._email = State(initialValue: initialEmail)
    self._bio = State(initialValue: initialBio)
    self._image = State(initialValue: initialImage)
    self.initialName = initialName
    self.initialEmail = initialEmail
    self.initialBio = initialBio
    self.initialImage = initialImage
    self.onSave = onSave
    self.onCancel = onCancel
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: AppSpacing.large) {
          // Profile Photo Section
          VStack(spacing: AppSpacing.medium) {
            ZStack(alignment: .bottomTrailing) {
              if let image = image {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFill()
                  .frame(width: 140, height: 140)
                  .clipShape(Circle())
                  .overlay(
                    Circle()
                      .stroke(
                        LinearGradient(
                          colors: [AppColors.primaryGradientStart, AppColors.primaryGradientEnd],
                          startPoint: .topLeading,
                          endPoint: .bottomTrailing
                        ),
                        lineWidth: 4
                      )
                  )
              } else {
                Circle()
                  .fill(
                    LinearGradient(
                      colors: [AppColors.primaryGradientStart.opacity(0.3), AppColors.primaryGradientEnd.opacity(0.3)],
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    )
                  )
                  .frame(width: 140, height: 140)
                  .overlay(
                    Image(systemName: "person.fill")
                      .font(.system(size: 60))
                      .foregroundColor(.white.opacity(0.7))
                  )
              }

              // Camera icon button
              PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                Image(systemName: "camera.fill")
                  .font(.system(size: 16))
                  .foregroundColor(.white)
                  .padding(10)
                  .background(AppGradients.primary)
                  .clipShape(Circle())
              }
              .offset(x: -5, y: -5)
            }
          }
          .padding(.top, AppSpacing.large)

          // Form Fields
          VStack(spacing: AppSpacing.large) {
            // Name Field
            VStack(alignment: .leading, spacing: 8) {
              Text("Name")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

              TextField("Enter your name", text: $name)
                .textContentType(.name)
                .autocorrectionDisabled()
                .padding(AppSpacing.small)
                .background(
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                )
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }

            // Email Field
            VStack(alignment: .leading, spacing: 8) {
              Text("Email")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

              VStack(alignment: .leading, spacing: 6) {
                TextField("Enter your email", text: $email)
                  .keyboardType(.emailAddress)
                  .textInputAutocapitalization(.never)
                  .textContentType(.emailAddress)
                  .padding(AppSpacing.small)
                  .background(
                    RoundedRectangle(cornerRadius: 12)
                      .fill(Color(.systemBackground))
                      .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                  )
                  .overlay(
                    RoundedRectangle(cornerRadius: 12)
                      .stroke(
                        !isEmailValid && !email.isEmpty ? Color.red : Color(.systemGray4),
                        lineWidth: !isEmailValid && !email.isEmpty ? 2 : 1
                      )
                  )

                if !isEmailValid && !email.isEmpty {
                  HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                      .font(.caption)
                    Text("Please enter a valid email address")
                      .font(.caption)
                  }
                  .foregroundColor(.red)
                  .padding(.leading, AppSpacing.small)
                }
              }
            }

            // Bio Field
            VStack(alignment: .leading, spacing: 8) {
              Text("Bio")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)

              ZStack(alignment: .topLeading) {
                if bio.isEmpty {
                  Text("Tell us about yourself...")
                    .foregroundColor(.secondary)
                    .padding()
                }

                TextEditor(text: $bio)
                  .frame(minHeight: 120)
                  .scrollContentBackground(.hidden)
                  .padding(AppSpacing.small)
              }
              .background(
                RoundedRectangle(cornerRadius: 12)
                  .fill(Color(.systemBackground))
                  .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
              )
              .overlay(
                RoundedRectangle(cornerRadius: 12)
                  .stroke(Color(.systemGray4), lineWidth: 1)
              )
            }
          }
          .padding(.horizontal, AppSpacing.medium)
        }
        .padding(.bottom, AppSpacing.large)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Text("Profile")
            .font(.system(size: AppFontSize.headerMedium))
            .fontWeight(.bold)
        }
        
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Cancel") {
            onCancel()
            dismiss()
          }
          .foregroundColor(.blue)
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            onSave(name, email, bio, image)
            dismiss()
          } label: {
            Image(systemName: "square.and.arrow.down")
              .foregroundColor(.blue)
          }
          .disabled(!isEmailValid && !email.isEmpty)
        }
      }
      .onAppear {
        // Load profile data when view appears
        let loaded = profileManager.loadProfile()
        name = loaded.info.name
        email = loaded.info.email
        bio = loaded.info.bio
        image = loaded.image
      }
      .onChange(of: selectedItem) { _, newItem in
        guard let newItem else { return }
        Task {
          if let data = try? await newItem.loadTransferable(type: Data.self),
             let uiImage = UIImage(data: data) {
            await MainActor.run {
              self.image = uiImage
            }
          }
        }
      }
    }
  }
  
  private var isEmailValid: Bool {
    // Simple email validation; allows empty (user may not want to set email yet)
    if email.isEmpty { return true }
    let regex = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
    return email.range(of: regex, options: [.regularExpression, .caseInsensitive]) != nil
  }
}

#Preview {
  ProfileView(
    initialName: "Lucas",
    initialEmail: "lucas@example.com",
    initialBio: "Traveler. Coffee enthusiast. Journal keeper.",
    initialImage: nil,
    onSave: { name, email, bio, image in
      print("Saved:", name, email, bio, image as Any)
    },
    onCancel: {
      print("Cancelled")
    }
  )
}
