//
//  YourBidsSection.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

struct ActiveBidRow: Identifiable {
    let index: Int
    let vehicle: Vehicle
    let state: LiveBidState

    var id: String { vehicle.id }
}

struct YourBidsSection: View {
    let rows: [ActiveBidRow]
    let timing: (Int) -> AuctionTiming
    let onTapBid: (Vehicle) -> Void

    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            if isExpanded {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(rows) { row in
                            BidTickerCardView(
                                vehicle: row.vehicle,
                                state: row.state,
                                timing: timing(row.index)
                            ) {
                                onTapBid(row.vehicle)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background(Color(.systemBackground))
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Button {
                withAnimation(.snappy) {
                    isExpanded.toggle()
                }
            } label: {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption.weight(.bold))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)

            Text("My bids")
                .font(.headline)

            Text("\(rows.count) active")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}
