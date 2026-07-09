//
//  TheBlockTests.swift
//  TheBlockTests
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Testing
import Foundation
@testable import TheBlock

struct TheBlockTests {
    
    struct VehicleRepositoryTests {
        @Test func loadsAllVehiclesWithoutThrowing() throws {
            let repository = BundledVehicleRepository()
            let vehicles = try repository.loadVehicles()
            #expect(vehicles.count == 200)
        }
    }
    
    @MainActor
    struct BiddingEngineTests {
        @Test func minimumNextBidRoundsUpTo500PlusOneStep() {
            let engine = BiddingEngine()
            
            #expect(engine.minimumNextBid(for: vehicle(currentBid: 0)) == 500)
            #expect(engine.minimumNextBid(for: vehicle(currentBid: 21_000)) == 21_500)
            #expect(engine.minimumNextBid(for: vehicle(currentBid: 22_001)) == 23_000)
            #expect(engine.minimumNextBid(for: vehicle(currentBid: 22_500)) == 23_000)
            #expect(engine.minimumNextBid(for: vehicle(currentBid: 22_501)) == 23_500)
        }
        
        @Test func displayedCurrentBidFallsBackToStartingBidWhenNoActivity() {
            let engine = BiddingEngine()
            let subject = vehicle(currentBid: nil, startingBid: 15_000)
            
            #expect(engine.displayedCurrentBid(for: subject) == 15_000)
        }
        
        @Test func canPlaceBidRespectsMinimum() {
            let engine = BiddingEngine()
            let subject = vehicle(currentBid: 21_000) // minimum = 21,500
            
            #expect(engine.canPlaceBid(21_500, on: subject))
            #expect(engine.canPlaceBid(22_000, on: subject))
            #expect(!engine.canPlaceBid(21_499, on: subject))
        }
        
        @Test func placeBidTakesLeadingAndIncrementsDisplayedCount() {
            let engine = BiddingEngine()
            let subject = vehicle(currentBid: 21_000, bidCount: 5)
            
            engine.placeBid(22_000, on: subject)
            #expect(engine.state(for: subject.id)?.status == .leading)
            #expect(engine.displayedCurrentBid(for: subject) == 22_000)
            #expect(engine.displayedBidCount(for: subject) == 6)
            
            engine.placeBid(22_500, on: subject)
            #expect(engine.displayedBidCount(for: subject) == 7)
        }
        
        @Test func placeBidBelowMinimumIsRejected() {
            let engine = BiddingEngine()
            let subject = vehicle(currentBid: 21_000)
            
            engine.placeBid(21_000, on: subject)
            #expect(engine.state(for: subject.id) == nil)
        }

        @Test func seedDemoBidsDoesNotOverwriteExistingBids() {
            let engine = BiddingEngine()
            let first = vehicle(currentBid: 21_000)
            let second = vehicle(currentBid: 25_000)

            engine.placeBid(22_000, on: first)
            engine.seedDemoBids(using: [first, second])

            #expect(engine.displayedCurrentBid(for: first) == 22_000)
            #expect(engine.displayedBidCount(for: first) == 1)
            #expect(engine.state(for: second.id) == nil)
        }

        @Test func placeBuyNowUsesVehicleBuyNowPriceWithoutCreatingActiveBid() {
            let engine = BiddingEngine()
            let subject = vehicle(currentBid: 21_000, bidCount: 3, buyNowPrice: 35_000)

            engine.placeBuyNow(on: subject)

            #expect(engine.isPurchased(subject))
            #expect(engine.state(for: subject.id) == nil)
            #expect(engine.displayedCurrentBid(for: subject) == 35_000)
            #expect(engine.displayedBidCount(for: subject) == 4)
        }

        @Test func placeBuyNowClearsExistingActiveBid() {
            let engine = BiddingEngine()
            let subject = vehicle(currentBid: 21_000, bidCount: 3, buyNowPrice: 35_000)

            engine.placeBid(22_000, on: subject)
            engine.placeBuyNow(on: subject)

            #expect(engine.isPurchased(subject))
            #expect(engine.state(for: subject.id) == nil)
            #expect(engine.displayedCurrentBid(for: subject) == 35_000)
            #expect(engine.displayedBidCount(for: subject) == 5)
        }
        
        private func vehicle(
            currentBid: Decimal? = 20_000,
            startingBid: Decimal = 10_000,
            bidCount: Int? = nil,
            buyNowPrice: Decimal? = nil
        ) -> Vehicle {
            Vehicle(
                id: "test-\(UUID().uuidString)",
                vin: "TEST",
                year: 2023,
                make: "Test",
                model: "Test",
                trim: "Test",
                bodyStyle: "sedan",
                exteriorColor: "black",
                interiorColor: "black",
                engine: "V6",
                transmission: "automatic",
                drivetrain: "FWD",
                odometerKm: 50_000,
                fuelType: "gasoline",
                conditionGrade: 3.5,
                conditionReport: "test",
                damageNotes: [],
                titleStatus: "clean",
                province: "ON",
                city: "Toronto",
                auctionStart: .now,
                startingBid: startingBid,
                reservePrice: nil,
                buyNowPrice: buyNowPrice,
                images: [],
                sellingDealership: "Test",
                lot: "T-001",
                currentBid: currentBid,
                bidCount: bidCount
            )
        }
    }
    
    struct InventoryFiltersTests {
        @Test func emptyFiltersMatchEverything() {
            let filters = InventoryFilters()
            #expect(filters.matches(vehicle: .sample, displayedBid: 34_000, timing: .live(timeLeft: 600)))
        }
        
        @Test func maxBidRejectsBidsAboveBudget() {
            var filters = InventoryFilters()
            filters.maxBid = 30_000
            
            #expect(filters.matches(vehicle: .sample, displayedBid: 25_000, timing: .live(timeLeft: 600)))
            #expect(!filters.matches(vehicle: .sample, displayedBid: 31_000, timing: .live(timeLeft: 600)))
        }
        
        @Test func auctionStatusFilterMatchesOnlySelectedState() {
            var filters = InventoryFilters()
            filters.auctionStatus = .live
            
            #expect(filters.matches(vehicle: .sample, displayedBid: 25_000, timing: .live(timeLeft: 600)))
            #expect(!filters.matches(vehicle: .sample, displayedBid: 25_000, timing: .ended))
            #expect(!filters.matches(vehicle: .sample, displayedBid: 25_000, timing: .upcoming(startsIn: 300)))
        }
    }
}
