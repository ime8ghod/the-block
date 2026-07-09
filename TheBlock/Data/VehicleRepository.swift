//
//  VehicleRepository.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation

protocol VehicleRepository {
    func loadVehicles() throws -> [Vehicle]
}

struct BundledVehicleRepository: VehicleRepository {
    // The challenge is frontend-only, so the bundled JSON acts as the data source.
    private let fileName: String

    init(fileName: String = "vehicles") {
        self.fileName = fileName
    }

    func loadVehicles() throws -> [Vehicle] {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw RepositoryError.fileNotFound
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(Self.auctionDateFormatter)
        do {
            return try decoder.decode([Vehicle].self, from: data)
        } catch {
            throw RepositoryError.decoding(error)
        }
    }

    private static let auctionDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }()
}

enum RepositoryError: Error {
    case fileNotFound
    case decoding(Error)
}
