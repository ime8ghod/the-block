//
//  VehicleDetailView.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

struct VehicleDetailView: View {
    let vehicle: Vehicle
    let index: Int
    let auctionAnchor: Date
    let biddingEngine: BiddingEngine
    let ticker: Ticker

    @State private var bidTarget: Vehicle?
    @State private var bidSheetMode: BidSheetMode = .bid

    private var state: LiveBidState? {
        biddingEngine.state(for: vehicle.id)
    }

    private var isPurchased: Bool {
        biddingEngine.isPurchased(vehicle)
    }

    private var timing: AuctionTiming {
        normalizedTiming(for: index, now: ticker.now, anchor: auctionAnchor)
    }

    private var reserveStatus: (text: String, tint: Color)? {
        guard let reservePrice = vehicle.reservePrice else { return nil }
        return biddingEngine.displayedCurrentBid(for: vehicle) >= reservePrice
            ? ("Reserve met", .green)
            : ("Reserve not met", .orange)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                photoGallery
                header
                bidOverview
                statusBadgesSection
                specsSection
                dealershipSection
                conditionReportSection
                damageNotesSection
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomBidBar
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $bidTarget, onDismiss: clearBidSheetState) { vehicle in
            BidSheetView(
                vehicle: vehicle,
                index: index,
                auctionAnchor: auctionAnchor,
                biddingEngine: biddingEngine,
                ticker: ticker,
                mode: bidSheetMode
            ) {
                bidTarget = nil
                bidSheetMode = .bid
            }
            .presentationDetents([.medium, .large])
        }
    }

    private var photoGallery: some View {
        TabView {
            ForEach(vehicle.images, id: \.self) { urlString in
                AsyncImage(url: vehicleImageURL(from: urlString)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    default:
                        Color(.secondarySystemBackground)
                            .overlay(Image(systemName: "car.fill").foregroundStyle(.secondary))
                    }
                }
                .clipped()
            }
        }
        .tabViewStyle(.page)
        .frame(height: 220)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(String(vehicle.year)) \(vehicle.make) \(vehicle.model) \(vehicle.trim)")
                .font(.title3.weight(.semibold))
            Text("VIN \(vehicle.vin) · Lot \(vehicle.lot)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var bidOverview: some View {
        bidCard
            .padding(.horizontal, 16)
            .padding(.top, 12)
    }

    private var bidCard: some View {
        HStack(alignment: .center, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Current bid · \(biddingEngine.displayedBidCount(for: vehicle)) bids")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(biddingEngine.displayedCurrentBid(for: vehicle).currencyLabel)
                    .font(.title3.weight(.bold))
                Text(timing.label)
                    .font(.caption)
                    .foregroundStyle(timing.isEnded ? Color.secondary : Color.red)
                if let reserveStatus {
                    badge(reserveStatus.text, tint: reserveStatus.tint)
                }
            }

            Spacer(minLength: 12)

            if let buyNowPrice = vehicle.buyNowPrice,
               !isPurchased,
               timing.isLive,
               biddingEngine.displayedCurrentBid(for: vehicle) < buyNowPrice {
                Button {
                    presentBuyNowSheet(for: buyNowPrice)
                } label: {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Buy now")
                            .font(.caption.weight(.semibold))
                        Text(buyNowPrice.currencyLabel)
                            .font(.subheadline.weight(.bold))
                    }
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 6))
                .controlSize(.regular)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var statusBadgesSection: some View {
        HStack(spacing: 8) {
            badge(vehicle.titleStatus.capitalized,
                  tint: vehicle.titleStatus.lowercased() == "clean" ? .green : .orange)
            badge("Grade \(String(format: "%.1f", vehicle.conditionGrade))", tint: .green)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    private var specsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionCaption("Specs")

            VStack(spacing: 0) {
                specRow(icon: "car.fill", label: "Body style", value: vehicle.bodyStyle)
                Divider().padding(.leading, 40)
                specRow(icon: "bolt.fill", label: "Engine", value: vehicle.engine)
                Divider().padding(.leading, 40)
                specRow(icon: "gearshape.fill", label: "Transmission", value: vehicle.transmission.capitalized)
                Divider().padding(.leading, 40)
                specRow(icon: "steeringwheel", label: "Drivetrain", value: vehicle.drivetrain)
                Divider().padding(.leading, 40)
                specRow(icon: "fuelpump.fill", label: "Fuel type", value: vehicle.fuelType.capitalized)
                Divider().padding(.leading, 40)
                specRow(icon: "gauge", label: "Odometer", value: "\(vehicle.odometerKm.formatted()) km")
                Divider().padding(.leading, 40)
                specRow(icon: "paintpalette.fill", label: "Exterior", value: vehicle.exteriorColor)
                Divider().padding(.leading, 40)
                specRow(icon: "square.stack.3d.up.fill", label: "Interior", value: vehicle.interiorColor)
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var dealershipSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            sectionCaption("Selling dealership")
            Text(vehicle.sellingDealership).font(.subheadline.weight(.medium))
            Text("\(vehicle.city), \(vehicle.province)").font(.caption).foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var conditionReportSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            sectionCaption("Condition report")
            Text(vehicle.conditionReport).font(.subheadline)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }

    private var damageNotesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            if vehicle.damageNotes.isEmpty {
                Label("No damages reported", systemImage: "checkmark.seal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
            } else {
                Label("Damage notes", systemImage: "exclamationmark.triangle")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.orange)
                ForEach(vehicle.damageNotes, id: \.self) { note in
                    Text("• \(note)")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(vehicle.damageNotes.isEmpty ? Color.green.opacity(0.12) : Color.orange.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    private var bottomBidBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(biddingEngine.displayedCurrentBid(for: vehicle).currencyLabel)
                        .font(.headline.weight(.bold))
                    Text("current bid")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Text(timing.label)
                    .font(.caption)
                    .foregroundStyle(timing.isEnded ? Color.secondary : Color.red)
            }
            Spacer()
            if isPurchased {
                Text("Purchased")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.green)
            } else if timing.isLive {
                Button(state?.status == .outbid ? "Raise bid" : "Bid") {
                    presentBidSheet()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 6))
                .controlSize(.large)
                .tint(state?.status == .outbid ? .red : .accentColor)
            } else {
                Text(timing.isEnded ? "Ended" : "Not started")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Rectangle().fill(Color(.separator)).frame(height: 0.5)
        }
        .shadow(color: .black.opacity(0.06), radius: 6, y: -3)
    }

    private func presentBidSheet() {
        bidSheetMode = .bid
        bidTarget = vehicle
    }

    private func presentBuyNowSheet(for buyNowPrice: Decimal) {
        let amount = NSDecimalNumber(decimal: buyNowPrice).intValue
        bidSheetMode = .buyNow(amount: amount)
        bidTarget = vehicle
    }

    private func clearBidSheetState() {
        bidTarget = nil
        bidSheetMode = .bid
    }

    private func sectionCaption(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.caption.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func specRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
    }

    private func badge(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(tint.opacity(0.15))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack {
        VehicleDetailView(
            vehicle: .sample,
            index: 3,
            auctionAnchor: .now,
            biddingEngine: BiddingEngine(),
            ticker: Ticker()
        )
    }
}
