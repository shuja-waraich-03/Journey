//
//  SearchBar.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

import SwiftUI

struct SearchBar: View {
  @Binding var searchText: String
  @Binding var sortOption: JournalSortOption
  let onSearchChange: (String) -> Void

  @State private var searchTask: Task<Void, Never>?

  var body: some View {
    HStack(spacing: AppSpacing.small) {
      TextField("Search for journals", text: $searchText)
        .padding(AppSpacing.small)
        .cardInputStyle()
//        .background(Color(.systemGray6))
//        .cornerRadius(8)
        .onChange(of: searchText) { oldValue, newValue in
          searchTask?.cancel()
          searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            onSearchChange(newValue)
          }
        }
        SortButton(
          sortOption: $sortOption,
          onSortChange: {
            // when user picks a new sort, re-run filterJournals()
            onSearchChange(searchText)
          }
        )
      }
      .padding(.horizontal, AppSpacing.medium)
      .padding(.top, AppSpacing.medium)
  }
}
