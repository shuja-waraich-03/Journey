//
//  JournalListView.swift
//  Journey
//
//  Created by Camposm on 11/12/25.
//

/**
 * JournalListView - Displays a list of journal cards
 */

import SwiftUI

struct JournalListView: View {
  /* journals to display */
  let journals: [Journal]

  /* callback when journal is tapped */
  let onTap: (Journal) -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: AppSpacing.medium) {
        ForEach(journals) { journal in
          JournalCard(journal: journal, onTap: {
            onTap(journal)
          })
          .id(journal.id) /* explicit ID prevents SwiftUI from recreating views */
        }
      }
      .padding(.horizontal, AppSpacing.medium)
    }
  }
}
