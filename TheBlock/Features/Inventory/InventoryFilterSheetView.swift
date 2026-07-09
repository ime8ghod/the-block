//
//  InventoryFilterSheetView.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI


struct InventoryFilterSheetView: View {
    let filters: InventoryFilters
    let onApply: (InventoryFilters) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draft: InventoryFilters

    init(filters: InventoryFilters, onApply: @escaping (InventoryFilters) -> Void) {
        self.filters = filters
        self.onApply = onApply
        _draft = State(initialValue: filters)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    auctionSection
                    budgetSection
                    riskSection
                }
                .padding(16)
            }
            .background(Color(.systemBackground))
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Reset") { draft = InventoryFilters() }
                        .disabled(draft.isEmpty)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private var auctionSection: some View {
        section("Auction status") {
            Picker("Status", selection: $draft.auctionStatus) {
                Text("Any").tag(nil as AuctionStatusFilter?)
                ForEach(AuctionStatusFilter.allCases) { status in
                    Text(status.rawValue).tag(status as AuctionStatusFilter?)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var budgetSection: some View {
        section("Max bid") {
            HStack {
                Text(draft.maxBid.map { $0.currencyLabel } ?? "Any budget")
                    .foregroundStyle(.secondary)
                Spacer()
                if draft.maxBid != nil {
                    Button("Clear") { draft.maxBid = nil }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }

            Slider(
                value: Binding(
                    get: { Double(draft.maxBid ?? 100_000) },
                    set: { draft.maxBid = Int(($0 / 500).rounded()) * 500 }
                ),
                in: 5_000...100_000,
                step: 500
            )
        }
    }

    private var riskSection: some View {
        section("Risk") {
            Toggle("Clean title only", isOn: $draft.cleanTitleOnly)
        }
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content()
        }
    }
}
