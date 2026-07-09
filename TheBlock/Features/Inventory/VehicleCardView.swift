//
//  VehicleCardView.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

struct VehicleCardView: View {
    let vehicle: Vehicle
    let state: LiveBidState?
    let displayedBid: Decimal
    let displayedBidCount: Int
    let timing: AuctionTiming
    let isPurchased: Bool
    let onTapCTA: () -> Void

    private var imageURL: URL? {
        vehicle.images.first.flatMap(vehicleImageURL(from:))
    }

    private var reserveBadge: (text: String, tint: Color)? {
        guard let reservePrice = vehicle.reservePrice else { return nil }
        return displayedBid >= reservePrice
            ? ("Reserve met", .green)
            : ("Reserve not met", .orange)
    }

    private var canShowBidButton: Bool {
        guard !isPurchased, timing.isLive else { return false }
        if state?.status != .leading { return true }
        guard let reservePrice = vehicle.reservePrice else { return false }
        return displayedBid < reservePrice
    }

    var body: some View {
        HStack(spacing: 12) {
            vehicleImage

            VStack(alignment: .leading, spacing: 6) {
                header
                bidRow
            }
            .padding(.vertical, 9)
            .padding(.trailing, 10)
        }
        .frame(height: 128)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.separator), lineWidth: 0.5))
    }

    private var vehicleImage: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            default:
                Color(.tertiarySystemFill)
                    .overlay(Image(systemName: "car.fill").foregroundStyle(.secondary))
            }
        }
        .frame(width: 132, height: 128)
        .clipped()
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 4) {
                if let state {
                    overlayTag(
                        state.status == .leading ? "Leading" : "Outbid",
                        tint: state.status == .leading ? .green : .red
                    )
                }
            }
            .padding(6)
        }
    }

    private func overlayTag(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(tint.opacity(0.9))
            .foregroundStyle(.white)
            .clipShape(Capsule())
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(String(vehicle.year)) \(vehicle.make) \(vehicle.model)")
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            HStack(spacing: 6) {
                badge(vehicle.titleStatus.capitalized,
                      tint: vehicle.titleStatus.lowercased() == "clean" ? .green : .orange)

                Text(vehicle.transmission.capitalized)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Text("\(vehicle.odometerKm.formatted()) km · \(vehicle.city), \(vehicle.province)")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 6) {
                if let reserveBadge {
                    badge(reserveBadge.text, tint: reserveBadge.tint)
                }
                if let buyNowPrice = vehicle.buyNowPrice {
                    Text("Buy now \(buyNowPrice.currencyLabel)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                        .lineLimit(1)
                }
            }
        }
    }

    private var bidRow: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(displayedBid.currencyLabel)
                        .font(.subheadline.weight(.bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    Text("current bid")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 6) {
                    Text(timing.label)
                        .foregroundStyle(timing.isEnded ? Color.secondary : Color.red)
                    if displayedBidCount > 0 {
                        Text("· \(displayedBidCount) bids")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.caption)
            }

            Spacer()

            if canShowBidButton {
                Button(state?.status == .outbid ? "Raise" : "Bid",
                       action: onTapCTA)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.roundedRectangle(radius: 6))
                    .controlSize(.small)
                    .tint(state?.status == .outbid ? .red : .accentColor)
            } else if isPurchased || !timing.isLive {
                Text(isPurchased ? "Purchased" : timing.isEnded ? "Ended" : "Upcoming")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }

    private func badge(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tint.opacity(0.15))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        VehicleCardView(
            vehicle: .sample,
            state: nil,
            displayedBid: Vehicle.sample.currentBid ?? Vehicle.sample.startingBid,
            displayedBidCount: Vehicle.sample.bidCount ?? 0,
            timing: .live(timeLeft: 12 * 60),
            isPurchased: false,
            onTapCTA: {}
        )

        VehicleCardView(
            vehicle: .sample,
            state: LiveBidState(status: .leading, myBid: 42000, bidsPlaced: 1),
            displayedBid: 42000,
            displayedBidCount: 10,
            timing: .live(timeLeft: 4 * 60),
            isPurchased: false,
            onTapCTA: {}
        )

        VehicleCardView(
            vehicle: .sample,
            state: LiveBidState(status: .outbid, myBid: 33500),
            displayedBid: 34000,
            displayedBidCount: 9,
            timing: .ended,
            isPurchased: false,
            onTapCTA: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
