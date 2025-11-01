import Foundation

struct SuggestedBrowserAction: Identifiable, Hashable {
    let id: UUID
    let title: String
    let detail: String
    let systemImageName: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        systemImageName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.systemImageName = systemImageName
    }
}

protocol BrowsingExperienceService {
    func loadRecentSessions() async -> [BrowsingSession]
    func loadSuggestedActions() async -> [SuggestedBrowserAction]
}

actor InMemoryBrowsingExperienceService: BrowsingExperienceService {
    private var sessions: [UUID: BrowsingSession]
    private var actions: [UUID: SuggestedBrowserAction]

    init(
        sessions: [BrowsingSession] = [],
        actions: [SuggestedBrowserAction] = []
    ) {
        self.sessions = Dictionary(uniqueKeysWithValues: sessions.map { ($0.id, $0) })
        self.actions = Dictionary(uniqueKeysWithValues: actions.map { ($0.id, $0) })
    }

    func loadRecentSessions() async -> [BrowsingSession] {
        sessions.values.sorted(by: { $0.lastViewedAt > $1.lastViewedAt })
    }

    func loadSuggestedActions() async -> [SuggestedBrowserAction] {
        actions.values.sorted(by: { $0.title < $1.title })
    }
}

