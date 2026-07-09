# The Block

## How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/ime8ghod/the-block.git
   cd the-block
2. Open the project in Xcode.
3. Select the TheBlock scheme.
4. Run the app on an iPhone simulator.

The app uses the bundled vehicles.json file, so there is no backend setup, database setup, or API key required.

## Time Spent

Approximately 4 hours. Since AI tools were explicitly allowed for this challenge, I used them to accelerate brainstorming, parts of the implementation, code reviews, unit test generation, and translating UI concepts into SwiftUI layouts. I treated AI as a coding assistant rather than an author—all product decisions, architectural choices, and the final implementation were my own.

## Assumptions and Scope

This project focuses on the core buyer experience rather than a complete auction platform.

It includes inventory browsing with search, filtering and sorting, a vehicle detail screen, a simple bidding flow with live UI updates, Buy Now support, reserve status, and a dedicated section to keep track of vehicles you’ve already bid on. Auctions can appear as live, upcoming, or ended.

To keep the project within the challenge scope, a few things were intentionally simplified. Bid state lives entirely in memory, so it resets when the app is restarted. There is no authentication, backend, checkout, payments, or dealer account management. Buy Now is simulated locally by marking the vehicle as purchased.

The auction timestamps provided in the datasett are synthetic, so the app normalizes them at runtime to present a realistic mix of live, upcoming, and ended auctions regardless of when the prototype is launched.

## Stack

- **Frontend:** SwiftUI, Swift 5.9 
- **Backend:** None
- **Database:** Bundled JSON file 

## What I Built

I built a native SwiftUI prototype of the buyer side of a vehicle auction marketplace.

The main flow lets buyers browse the inventory, search, filter and sort vehicles, inspect detailed vehicle information, and participate in auctions by placing bids or using Buy Now when available.

To help buyers keep track of ongoing auctions while continuing to source new inventory, the Inventory screen includes a dedicated “My Bids” section. Instead of forcing users to switch screens, it surfaces the vehicles they’ve already interacted with, highlighting whether they’re currently leading or have been outbid.

Vehicle cards surface the information I felt was most useful during browsing: auction status, current bid, bid count, reserve status, and the next available action. The detail screen expands on that with photos, specifications, condition report, damage notes, dealership information, and the bidding experience.

## Notable Decisions

This is intentionally a frontend-only prototype. Rather than spending time on backend infrastructure or persistence, I focused on the buyer experience and the product decisions around browsing and bidding.

I also chose not to introduce a ViewModel for every screen.At this stage, the application state is still relatively small, and most of the business logic already lives in dedicated types:

* VehicleRepository loads the bundled dataset.
* InventoryQuery is responsible for search, filtering, and sorting.
* AuctionTiming normalizes the auction states used by the prototype.
* BiddingEngine owns the bidding rules and session state.

Rather than introducing a separate “My Bids” screen, I chose to keep active bids directly within the Inventory experience. Professional buyers constantly switch between discovering new inventory and monitoring ongoing auctions, so keeping both together reduces context switching while keeping active bids visible.

The auction dates included in the dataset are synthetic, so I normalize them at runtime to keep the prototype usable. The goal isn’t to simulate real auction scheduling but to ensure reviewers can always interact with live, upcoming, and ended auctions.

I also kept Buy Now separate from the bidding flow. Bids follow the auction rules and minimum increments, while Buy Now is treated as a fixed-price purchase.

## Testing

Given the time available, I focused on the parts of the project where regressions are most likely.

I focused on unit testing the core business rules, including:

* loading the bundled vehicle data
* minimum bid calculation
* rejecting bids below the minimum
* bid count updates
* preserving user bids when demo bid state is initialized
* Buy Now pricing
* ensuring Buy Now purchases don’t appear in “My Bids”
* inventory filtering

I didn’t invest time in UI automation for this prototype. If I had to choose, I felt validating the bidding rules and inventory behavior provided much more value within the challenge’s time constraints.

## What I'd Do With More Time

If I continued working on the project, I’d remove the timing normalization once real auction dates are available from a backend.

Other improvements I’d prioritize include:

* Move more auction validation into the bidding domain.
* Persist bids and purchases between launches.
* implementing a real Buy Now purchase flow
* adding a small UI test suite for the core user journeys
* introducing a lightweight design system for reusable UI components
* breaking down some of the larger detail sections if the feature set continues to grow

Given the time constraint, I intentionally prioritized product decisions, code clarity, and the core buyer experience over feature completeness.
