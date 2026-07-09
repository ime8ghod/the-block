//
//  AuctionTiming.swift
//  TheBlock
//
//  Created by Imen Ghodhbani on 2026-07-08.
//

import Foundation

enum AuctionTiming {
    case live(timeLeft: TimeInterval)
    case upcoming(startsIn: TimeInterval)
    case ended
}

// normalizes timing from the row index to keep a stable mix of live, upcoming, and ended cars.
func normalizedTiming(for index: Int, now: Date = .now, anchor: Date = .now) -> AuctionTiming {
    let auctionDuration: TimeInterval = 45 * 60

    switch index % 4 {
    case 0:
        let startedAt = anchor.addingTimeInterval(-33 * 60)
        return liveTiming(startedAt: startedAt, duration: auctionDuration, now: now)
    case 1:
        let startedAt = anchor.addingTimeInterval(-10 * 60)
        return liveTiming(startedAt: startedAt, duration: auctionDuration, now: now)
    case 2:
        let startsAt = anchor.addingTimeInterval(20 * 60)
        if now < startsAt {
            return .upcoming(startsIn: startsAt.timeIntervalSince(now))
        }
        return liveTiming(startedAt: startsAt, duration: auctionDuration, now: now)
    default:
        return .ended
    }
}

private func liveTiming(startedAt: Date, duration: TimeInterval, now: Date) -> AuctionTiming {
    let endsAt = startedAt.addingTimeInterval(duration)
    let timeLeft = endsAt.timeIntervalSince(now)
    return timeLeft > 0 ? .live(timeLeft: timeLeft) : .ended
}

extension AuctionTiming {
    var label: String {
        switch self {
        case .live(let timeLeft): return "\(Self.clockLabel(timeLeft)) left"
        case .upcoming(let startsIn): return "Starts in \(Self.clockLabel(startsIn))"
        case .ended: return "Ended"
        }
    }

    private static func clockLabel(_ interval: TimeInterval) -> String {
        let seconds = max(0, Int(interval.rounded(.down)))
        return "\(seconds / 60):\(String(format: "%02d", seconds % 60))"
    }

    var isUrgent: Bool {
        if case .live(let timeLeft) = self { return timeLeft <= 300 }
        return false
    }

    var isLive: Bool {
        if case .live = self { return true }
        return false
    }

    var isEnded: Bool {
        if case .ended = self { return true }
        return false
    }
}
