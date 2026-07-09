//
//  InventoryView.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import SwiftUI

struct InventoryView: View {
    let repository: VehicleRepository
    let biddingEngine: BiddingEngine
    let ticker: Ticker

    @State private var vehicles: [Vehicle] = []
    @State private var searchText = ""
    @State private var loadError: String?
    @State private var bidTarget: Vehicle?
    @State private var isYourBidsExpanded = true
    @State private var isFilterSheetPresented = false
    @State private var navigationPath = NavigationPath()
    @State private var filters = InventoryFilters()
    @State private var sort = InventorySort.endingSoon
    // One anchor keeps the demo auction states stable while the ticker moves time forward.
    @State private var auctionAnchor = Date.now

    private var filteredRows: [InventoryRow] {
        InventoryQuery(
            searchText: searchText,
            filters: filters,
            sort: sort,
            now: ticker.now,
            auctionAnchor: auctionAnchor,
            biddingEngine: biddingEngine
        )
        .rows(from: vehicles)
    }

    private var myBidRows: [ActiveBidRow] {
        vehicles.enumerated().compactMap { index, vehicle in
            guard let state = biddingEngine.state(for: vehicle.id) else { return nil }
            return ActiveBidRow(index: index, vehicle: vehicle, state: state)
        }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if !myBidRows.isEmpty {
                        YourBidsSection(
                            rows: myBidRows,
                            timing: timing(for:),
                            onTapBid: { bidTarget = $0 },
                            isExpanded: $isYourBidsExpanded
                        )
                    }

                    inventoryControls
                    sectionTitle("Inventory", detail: "\(filteredRows.count) vehicles")
                        .padding(.top, 2)
                        .padding(.bottom, 10)
                        .background(Color(.systemBackground))

                    inventoryList
                }
            }
            .navigationTitle("Inventory")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search make, model, year, trim")
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(
                    vehicle: vehicle,
                    index: vehicles.firstIndex(where: { $0.id == vehicle.id }) ?? 0,
                    auctionAnchor: auctionAnchor,
                    biddingEngine: biddingEngine,
                    ticker: ticker
                )
            }
            .task(loadVehicles)
            .overlay {
                if let loadError {
                    Text(loadError)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .sheet(item: $bidTarget) { vehicle in
                BidSheetView(
                    vehicle: vehicle,
                    index: vehicles.firstIndex(where: { $0.id == vehicle.id }) ?? 0,
                    auctionAnchor: auctionAnchor,
                    biddingEngine: biddingEngine,
                    ticker: ticker
                ) {
                    bidTarget = nil
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(isPresented: $isFilterSheetPresented) {
                InventoryFilterSheetView(filters: filters) { newFilters in
                    filters = newFilters
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var inventoryControls: some View {
        HStack(spacing: 10) {
            Button {
                isFilterSheetPresented = true
            } label: {
                Label(filters.isEmpty ? "Filter" : "Filter · \(filters.activeCount)",
                      systemImage: "line.3.horizontal.decrease.circle")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)

            Spacer()

            Menu {
                ForEach(InventorySort.allCases) { option in
                    Button {
                        sort = option
                    } label: {
                        if sort == option {
                            Label(option.rawValue, systemImage: "checkmark")
                        } else {
                            Text(option.rawValue)
                        }
                    }
                }
            } label: {
                Label(sort.rawValue, systemImage: "arrow.up.arrow.down")
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .font(.subheadline.weight(.semibold))
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private var inventoryList: some View {
        ScrollView {
            if filteredRows.isEmpty {
                emptySearchState
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(filteredRows, id: \.vehicle.id) { item in
                        VehicleCardView(
                            vehicle: item.vehicle,
                            state: biddingEngine.state(for: item.vehicle.id),
                            displayedBid: biddingEngine.displayedCurrentBid(for: item.vehicle),
                            displayedBidCount: biddingEngine.displayedBidCount(for: item.vehicle),
                            timing: timing(for: item.index),
                            isPurchased: biddingEngine.isPurchased(item.vehicle)
                        ) {
                            bidTarget = item.vehicle
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigationPath.append(item.vehicle)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
    }

    private var emptySearchState: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.title2)
                .foregroundStyle(.secondary)

            Text("No vehicles found")
                .font(.subheadline.weight(.semibold))

            Text("Try another make, model, year, or trim.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
    }

    private func sectionTitle(_ title: String, detail: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.headline)

            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(.horizontal, 16)
    }

    private func timing(for index: Int) -> AuctionTiming {
        normalizedTiming(for: index, now: ticker.now, anchor: auctionAnchor)
    }

    private func loadVehicles() async {
        do {
            vehicles = try repository.loadVehicles()
            biddingEngine.seedDemoBids(using: vehicles)
        } catch {
            loadError = "Couldn't load inventory."
        }
    }
}

#Preview {
    InventoryView(
        repository: BundledVehicleRepository(),
        biddingEngine: BiddingEngine(),
        ticker: Ticker()
    )
}
