//
//  LiveActivityIntent.swift
//  xdrip
//
//  Created by Marian Dugaesescu on 13/10/2024 / Edited by Paul Plant on 06/02/2025.
//  Copyright © 2024 Johan Degraeve. All rights reserved.
//

import AppIntents

@available(iOS 16.0, *)
struct RestartLiveActivityIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Restart Live Activity"
    static var description = IntentDescription("Restarts the glucose monitoring live activity.", categoryName: "Live Activity")

    @MainActor
    func perform() async throws -> some IntentResult {
        // restart the live activity via the LiveActivityManager singleton
        LiveActivityManager.shared.restartFromIntent()
        return .result()
    }
}
