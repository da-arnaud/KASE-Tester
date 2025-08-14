//
//  ConversationsListView.swift
//  XMKasiaMsg
//
//  Created by Daniel Arnaud on 27/06/2025.
//

import SwiftUI

struct ConversationsListView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("(placeholder) No conversations yet")
            }
            .navigationTitle("Conversations")
        }
        .background(Color("background-solea-blue").ignoresSafeArea())
    }
}

