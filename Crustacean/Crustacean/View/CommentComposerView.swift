//
//  CommentComposerView.swift
//  Crustacean
//
//  Created by Sayan Goswami on 23/08/2025.
//

import SwiftUI

struct CommentComposerView: View {
    let storyId: String
    let storyTitle: String?
    let parentCommentShortId: String?
    let replyingToUsername: String?
    var onPosted: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var commentBody = ""
    @State private var isPosting = false
    @State private var errorMessage: String?

    @FocusState private var isEditorFocused: Bool

    private var trimmedBody: String {
        commentBody.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canPost: Bool {
        !trimmedBody.isEmpty && !isPosting
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                header

                editor

                if let errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                        .font(.callout)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.opacity)
                }

                HStack {
                    Text("Markdown supported")
                    Spacer()
                    Text("\(commentBody.count) characters")
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isPosting)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await post()
                        }
                    } label: {
                        if isPosting {
                            ProgressView()
                        } else {
                            Text("Post")
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(!canPost)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            isEditorFocused = true
        }
    }

    var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.title3)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(replyingToUsername != nil ? "Reply to \(replyingToUsername!)" : "Comment on this story")
                    .font(.headline)

                if let storyTitle {
                    Text(storyTitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var editor: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $commentBody)
                .focused($isEditorFocused)
                .frame(minHeight: 140)
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.secondary.opacity(0.2), lineWidth: 1)
                )

            if commentBody.isEmpty {
                Text("Write a comment…")
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .foregroundStyle(.secondary)
                    .allowsHitTesting(false)
            }
        }
    }

    private func post() async {
        isPosting = true
        errorMessage = nil

        let result = await postComment(
            storyId: storyId,
            body: trimmedBody,
            parentCommentShortId: parentCommentShortId
        )

        switch result {
        case .success:
            onPosted?()
            dismiss()
        case .notLoggedIn:
            errorMessage = "You need to be logged in to comment."
        case .error(let message):
            errorMessage = message
        }

        isPosting = false
    }
}