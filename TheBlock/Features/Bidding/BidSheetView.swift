//
//  BidSheetView.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

enum BidSheetMode: Equatable {
    case bid
    case buyNow(amount: Int)
}

struct BidSheetView: View {
    let vehicle: Vehicle
    let index: Int
    let auctionAnchor: Date
    let biddingEngine: BiddingEngine
    let ticker: Ticker
    let mode: BidSheetMode
    let onPlaced: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var amount: Int
    @State private var amountText: String

    private let bidStep = 500

    init(
        vehicle: Vehicle,
        index: Int,
        auctionAnchor: Date = .now,
        biddingEngine: BiddingEngine,
        ticker: Ticker,
        mode: BidSheetMode = .bid,
        onPlaced: @escaping () -> Void
    ) {
        self.vehicle = vehicle
        self.index = index
        self.auctionAnchor = auctionAnchor
        self.biddingEngine = biddingEngine
        self.ticker = ticker
        self.mode = mode
        self.onPlaced = onPlaced
        let startingAmount: Int
        switch mode {
        case .bid:
            startingAmount = biddingEngine.minimumNextBid(for: vehicle)
        case .buyNow(let amount):
            startingAmount = amount
        }
        _amount = State(initialValue: startingAmount)
        _amountText = State(initialValue: String(startingAmount))
    }

    private var currentBid: Decimal {
        biddingEngine.displayedCurrentBid(for: vehicle)
    }

    private var timing: AuctionTiming {
        normalizedTiming(for: index, now: ticker.now, anchor: auctionAnchor)
    }

    private var isEnded: Bool {
        if case .ended = timing { return true }
        return false
    }

    private var minimumBid: Int {
        biddingEngine.minimumNextBid(for: vehicle)
    }

    private var canPlaceBid: Bool {
        timing.isLive && Int(amountText) != nil && biddingEngine.canPlaceBid(amount, on: vehicle)
    }

    private var canBuyNow: Bool {
        guard case .buyNow(let amount) = mode else { return false }
        return !biddingEngine.isPurchased(vehicle) && timing.isLive && Decimal(amount) > currentBid
    }

    private var isBuyNowMode: Bool {
        if case .buyNow = mode { return true }
        return false
    }

    private var reserveStatus: (text: String, tint: Color)? {
        guard let reservePrice = vehicle.reservePrice else { return nil }
        return currentBid >= reservePrice
            ? ("Reserve met", .green)
            : ("Reserve not met", .orange)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            bidSummary
            if isBuyNowMode {
                fixedBuyNowAmount
            } else {
                amountEntry
            }
            submitButton
        }
        .padding(16)
        .presentationDragIndicator(.visible)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(isBuyNowMode ? "Buy now" : "Place bid")
                .font(.headline)
            Text("\(String(vehicle.year)) \(vehicle.make) \(vehicle.model)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var bidSummary: some View {
        VStack(spacing: 10) {
            summaryRow("Current bid", currentBid.currencyLabel)
            if case .buyNow(let amount) = mode {
                summaryRow("Buy now price", amount.currencyLabel)
            } else {
                summaryRow("Minimum next bid", minimumBid.currencyLabel)
            }
            summaryRow("Auction", timing.label)

            let count = biddingEngine.displayedBidCount(for: vehicle)
            if count > 0 {
                summaryRow("Bid count", "\(count)")
            }

            if let reserveStatus {
                HStack {
                    Text(reserveStatus.text)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(reserveStatus.tint.opacity(0.15))
                .foregroundStyle(reserveStatus.tint)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var amountEntry: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your bid")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button {
                    setAmount(max(minimumBid, amount - bidStep))
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.bordered)
                .disabled(amount <= minimumBid)

                HStack(spacing: 2) {
                    Text("$")
                        .foregroundStyle(.secondary)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2.weight(.bold))
                        .onChange(of: amountText) { _, newValue in
                            updateAmount(from: newValue)
                        }
                }
                .padding(.horizontal, 10)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))

                Button {
                    setAmount(amount + bidStep)
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.bordered)
            }

            Text("Minimum \(minimumBid.currencyLabel). Bids move in \(bidStep.currencyLabel) increments.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var fixedBuyNowAmount: some View {
        // Buy now is a fixed confirmation flow; regular bids stay editable.
        VStack(alignment: .leading, spacing: 10) {
            Text("Buy now amount")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(amount.currencyLabel)
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private var submitButton: some View {
        Button {
            switch mode {
            case .bid:
                placeBid(amount)
            case .buyNow:
                buyNow()
            }
        } label: {
            Text(submitTitle)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 6))
        .controlSize(.large)
        .disabled(isBuyNowMode ? !canBuyNow : !canPlaceBid)
    }

    private var submitTitle: String {
        if isEnded { return "Auction ended" }
        if !timing.isLive { return "Auction not started" }

        switch mode {
        case .bid:
            return "Place bid"
        case .buyNow(let amount):
            return "Buy now for \(amount.currencyLabel)"
        }
    }

    private func placeBid(_ bidAmount: Int) {
        biddingEngine.placeBid(bidAmount, on: vehicle)
        onPlaced()
        dismiss()
    }

    private func buyNow() {
        biddingEngine.placeBuyNow(on: vehicle)
        onPlaced()
        dismiss()
    }

    private func setAmount(_ newAmount: Int) {
        amount = newAmount
        amountText = String(newAmount)
    }

    private func updateAmount(from text: String) {
        let digits = text.filter(\.isNumber)
        if digits != text {
            amountText = digits
            return
        }

        if let value = Int(digits) {
            amount = value
        } else {
            amount = 0
        }
    }

    private func summaryRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

}

#Preview {
    BidSheetView(
        vehicle: .sample,
        index: 0,
        biddingEngine: BiddingEngine(),
        ticker: Ticker()
    ) {}
}
