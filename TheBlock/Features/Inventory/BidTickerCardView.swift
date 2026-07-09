//
//  BidTickerCardView.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

struct BidTickerCardView: View {
    let vehicle: Vehicle
    let state: LiveBidState
    let timing: AuctionTiming
    let onTap: () -> Void

    private var isLeading: Bool { state.status == .leading }
    private var tint: Color { isLeading ? .green : .red }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 4) {
                statusTag

                Text("\(String(vehicle.year)) \(vehicle.make) \(vehicle.model)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(state.myBid.currencyLabel)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(timing.label)
                    .font(.caption2)
                    .foregroundStyle(timing.isEnded ? Color.secondary : Color.red)
                    .lineLimit(1)
            }
            .padding(10)
            .frame(width: 128, alignment: .leading)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var statusTag: some View {
        Text(isLeading ? "Leading" : "Outbid")
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(tint.opacity(0.15))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }

}
