//
//  JournalEditorView.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

/**
 * JournalEditorView - Create and edit journal entries
 *
 * This view handles both creating new journals and editing existing ones.
 * It includes a complete form with photo upload, text fields, date picker,
 * and automatic location fetching via GPS.
 */

import SwiftUI
import PhotosUI
import CoreLocation

struct JournalEditorView: View {
  /* environment value to dismiss this view (like a back button) */
  @Environment(\.dismiss) var dismiss

  /* location manager observes GPS location changes */
  @StateObject private var locationManager = LocationManager()

  /* journal being edited (nil if creating new journal) */
  let existingJournal: Journal?

  /* callback when journal is saved */
  let onSave: ((Journal) -> Void)?

  /* data manager for local storage */
  private let dataManager = JournalDataManager.shared
  private let imageManager = ImageManager.shared

  /* form field state variables */
  @State private var title: String = ""
  @State private var content: String = ""
  @State private var selectedDate: Date = Date()
  @State private var location: String = ""
  @State private var selectedImage: PhotosPickerItem?
  @State private var imageData: Data?
  @State private var showDatePicker = false
  @State private var showDeleteAlert = false

  /* tracks whether the user clicked the location button */
  @State private var isManualLocationRequest = false

  /* computed property to check if we're editing vs creating */
  var isEditing: Bool {
    existingJournal != nil
  }

  /* Custom initializer to support both create and edit modes */
  init(journal: Journal? = nil, onSave: ((Journal) -> Void)? = nil) {
    self.existingJournal = journal
    self.onSave = onSave
    /* initialize state from existing journal if editing */
    if let journal = journal {
      _title = State(initialValue: journal.title ?? "")
      _content = State(initialValue: journal.content ?? "")
      _selectedDate = State(initialValue: journal.createdAt)
      _location = State(initialValue: journal.location ?? "")

      /* load existing image if available */
      if let imageFilename = journal.images?.first,
         let uiImage = ImageManager.shared.loadImage(filename: imageFilename),
         let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
        _imageData = State(initialValue: jpegData)
      }
    }
  }
  
  private func handleSave() {
    /* save image if one was selected */
    var imageFilenames: [String] = []

    if let imageData = imageData {
      /* save new image */
      if let filename = imageManager.saveImage(imageData) {
        imageFilenames.append(filename)
      }
    } else if let existingJournal = existingJournal {
      /* keep existing images if no new image was selected */
      imageFilenames = existingJournal.images ?? []
    }

    /* create or update journal */
    var journal: Journal

    if let existingJournal = existingJournal {
      /* update existing journal */
      journal = Journal(
        id: existingJournal.id,
        title: title.isEmpty ? nil : title,
        location: location.isEmpty ? nil : location,
        content: content.isEmpty ? nil : content,
        images: imageFilenames.isEmpty ? nil : imageFilenames
      )
      journal.createdAt = existingJournal.createdAt
      journal.updatedAt = Date()
    } else {
      /* create new journal */
      journal = Journal(
        title: title.isEmpty ? nil : title,
        location: location.isEmpty ? nil : location,
        content: content.isEmpty ? nil : content,
        images: imageFilenames.isEmpty ? nil : imageFilenames
      )
      journal.createdAt = selectedDate
    }

    /* save to local storage */
    dataManager.addOrUpdateJournal(journal)

    /* notify parent */
    onSave?(journal)

    print("Saved journal: \(title)")
    dismiss()
  }

  private func handleDelete() {
    if let journal = existingJournal {
      dataManager.deleteJournal(withId: journal.id)
      onSave?(journal) // notify parent to reload
    }
    print("Deleted journal: \(title)")
    dismiss()
  }
  
  var body: some View {
    VStack(spacing: 0) {
      /* custom header */
      AppHeader(text: isEditing ? (existingJournal?.title ?? "Edit Journal") : "New Journal", showIcon: false, paddingStyle: .bottom)
      
      ScrollView {
        VStack(spacing: AppSpacing.medium) {
          /* photo upload card */
          PhotoUploadCard(imageData: $imageData, selectedImage: $selectedImage)
          
          VStack(spacing: AppSpacing.medium) {
            /* title field */
            VStack(alignment: .leading, spacing: AppSpacing.small) {
              Text("Title")
                .font(.system(size: AppFontSize.body))
                .fontWeight(.semibold)
              TextField("Enter journal title", text: $title)
                .padding(AppSpacing.small)
                .cardInputStyle()
            }
            
            /* date field */
            VStack(alignment: .leading, spacing: AppSpacing.small) {
              Text("Date")
                .font(.system(size: AppFontSize.body))
                .fontWeight(.semibold)
              Button(action: {
                showDatePicker.toggle()
              }) {
                HStack {
                  Text(selectedDate, style: .date)
                    .foregroundColor(.primary)
                  Spacer()
                  Image(systemName: "calendar")
                    .foregroundColor(.blue)
                }
                .padding(AppSpacing.small)
                .cardInputStyle()
              }
              if showDatePicker {
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                  .datePickerStyle(.wheel)
              }
            }
            
            /* location field */
            VStack(alignment: .leading, spacing: AppSpacing.small) {
              Text("Location")
                .font(.system(size: AppFontSize.body))
                .fontWeight(.semibold)
              HStack {
                TextField("Enter location", text: $location)
                Button(action: {
                  isManualLocationRequest = true
                  locationManager.requestLocation()
                }) {
                  Image(systemName: "location.fill")
                    .foregroundColor(.blue)
                }
              }
              .padding(AppSpacing.small)
              .cardInputStyle()
            }
            
            /* journal content - canvas style */
            VStack(alignment: .leading, spacing: AppSpacing.small) {
              Text("Journal Entry")
                .font(.system(size: AppFontSize.body))
                .fontWeight(.semibold)
              ZStack(alignment: .topLeading) {
                TextEditor(text: $content)
                  .frame(minHeight: 300)
                  .scrollContentBackground(.hidden)
                  .background(Color.clear)
                  .font(.system(size: 16, design: .default))

                /* placeholder */
                if content.isEmpty {
                  Text("Start writing your thoughts...")
                    .foregroundColor(Color(.placeholderText))
                    .font(.system(size: 16))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
                }
              }
            }

//            /* action buttons */
//            if isEditing {
//              HStack(spacing: AppSpacing.medium) {
//                /* delete button */
//                Button(action: {
//                  showDeleteAlert = true
//                }) {
//                  HStack {
//                    Image(systemName: "trash.fill")
//                      .font(.system(size: 16))
//                    Text("Delete")
//                      .fontWeight(.semibold)
//                  }
//                  .foregroundColor(.white)
//                  .padding(AppSpacing.small)
//                  .frame(maxWidth: .infinity)
//                  .background(Color.red)
//                  .cornerRadius(10)
//                }
//
//                /* save button */
//                GradientButton(text: "Save", icon: "checkmark", fullWidth: true, action: handleSave)
//              }
//            } else {
//              /* just save button for new journals */
//              GradientButton(text: "Create Journal", icon: "plus", fullWidth: true, action: handleSave)
//            }
          }
          .padding(.horizontal, AppSpacing.medium)
        }
        .padding(.top, AppSpacing.small)
        .padding(.bottom, AppSpacing.medium)
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
          dismiss()
        }) {
          HStack(spacing: 4) {
            Image(systemName: "chevron.left")
              .font(.system(size: 16, weight: .semibold))
            Text("Cancel")
          }
          .foregroundColor(.blue)
        }
      }

      /* delete button - only show when editing */
      if isEditing {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            showDeleteAlert = true
          }) {
            Image(systemName: "trash")
              .font(.system(size: 18))
              .foregroundColor(.red)
          }
        }
      }

      /* save button */
      ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: {
          handleSave()
        }) {
          Image(systemName: "square.and.arrow.down")
            .font(.system(size: 18))
            .foregroundColor(.blue)
        }
      }
    }
    .alert("Delete Journal", isPresented: $showDeleteAlert) {
      Button("Cancel", role: .cancel) { }
      Button("Delete", role: .destructive) {
        handleDelete()
      }
    } message: {
      Text("Are you sure you want to delete this journal? This action cannot be undone.")
    }
    .onAppear {
      /* auto-fetch location for new journals */
      if !isEditing {
        locationManager.requestLocation()
      }
    }
    .onChange(of: locationManager.locationString) { oldValue, newValue in
      /* update location field when location is fetched */
      if let newLocation = newValue {
        /* update if manual request or auto-fetch for new journal */
        if isManualLocationRequest || !isEditing {
          location = newLocation
          isManualLocationRequest = false
        }
      }
    }
  }
}

#Preview {
  /* preview for new journal */
  JournalEditorView()
}

#Preview("Editing Existing") {
  /* preview for editing existing journal */
  JournalEditorView(journal: Journal(
    title: "My Trip to Paris",
    location: "Paris, France",
    content: "Today was an amazing day exploring the Eiffel Tower and enjoying French cuisine."
  ))
}
