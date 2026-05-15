//
//  BlockedAppsSelectionView.swift
//  lifeisgame
//
//  Created by Codex on 15.05.2026.
//

import FamilyControls
import SwiftUI
import UIKit

struct BlockedAppsSelectionView: View {

    @ObservedObject var store: FocusBlockingSelectionStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPickerPresented = false
    @State private var isAuthorizing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Заблокированные приложения")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color(.label))

                    Text(summaryText)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color(.secondaryLabel))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    Task { await openPicker() }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "app.badge")
                        Text(isAuthorizing ? "Открываем..." : "Выбрать приложения")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(UIColor.main))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(isAuthorizing)

                if let authorizationError = store.authorizationError {
                    Text(authorizationError)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color(.systemRed))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()

                Button("Готово") {
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Color(.white))
                .foregroundStyle(Color(UIColor.main))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 18)
            .background(Color(UIColor.background).ignoresSafeArea())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(.label))
                    }
                }
            }
        }
        .familyActivityPicker(isPresented: $isPickerPresented, selection: $store.selection)
    }

    private var summaryText: String {
        let count = store.selectedItemsCount
        return count == 0 ? "Пока ничего не выбрано" : "Выбрано: \(count)"
    }

    private func openPicker() async {
        isAuthorizing = true
        let authorized = await store.requestAuthorization()
        isAuthorizing = false
        if authorized {
            isPickerPresented = true
        }
    }
}
