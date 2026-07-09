//
//  Vehicle.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation

struct Vehicle: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let vin: String
    let year: Int
    let make: String
    let model: String
    let trim: String
    let bodyStyle: String
    let exteriorColor: String
    let interiorColor: String
    let engine: String
    let transmission: String
    let drivetrain: String
    let odometerKm: Int
    let fuelType: String
    let conditionGrade: Double
    let conditionReport: String
    let damageNotes: [String]
    let titleStatus: String
    let province: String
    let city: String
    let auctionStart: Date
    let startingBid: Decimal
    let reservePrice: Decimal?
    let buyNowPrice: Decimal?
    let images: [String]
    let sellingDealership: String
    let lot: String
    let currentBid: Decimal?
    let bidCount: Int?
}

#if DEBUG
extension Vehicle {
    static let sample = Vehicle(
        id: "1dfa77c7-854a-4ada-bf95-6220eeb28d01",
        vin: "73RF5U464EX3GNV9T",
        year: 2023,
        make: "Ram",
        model: "1500",
        trim: "Laramie",
        bodyStyle: "truck",
        exteriorColor: "Dark Green",
        interiorColor: "White",
        engine: "5.7L HEMI V8",
        transmission: "automatic",
        drivetrain: "4WD",
        odometerKm: 58993,
        fuelType: "gasoline",
        conditionGrade: 3.8,
        conditionReport: "Fair condition overall. Interior has some wear but no major damage. A few exterior blemishes. Drives well.",
        damageNotes: ["Light hail damage on roof"],
        titleStatus: "clean",
        province: "British Columbia",
        city: "Surrey",
        auctionStart: .now,
        startingBid: 26500,
        reservePrice: 41000,
        buyNowPrice: 51500,
        images: [
            "https://placehold.co/800x600/1a1a2e/eaeaea?text=2023+Ram+1500+Photo+1",
            "https://placehold.co/800x600/1a1a2e/eaeaea?text=2023+Ram+1500+Photo+2"
        ],
        sellingDealership: "Fraser Valley Auto Group",
        lot: "A-0004",
        currentBid: 34000,
        bidCount: 9
    )
}
#endif
