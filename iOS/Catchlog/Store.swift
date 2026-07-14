import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [CatchEntry] = []
    @Published var isPro: Bool = false

    static let freeLimit = 23

    private let fileURL: URL = {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("catchlog_entries.json")
    }()

    init() {
        load()
        if entries.isEmpty {
            seed()
        }
    }

    func seed() {
        entries = [
        CatchEntry(name: "Largemouth Bass", species: "Micropterus salmoides", weight: "4.2 lb", waterbody: "Cedar Lake", lure: "Spinnerbait"),
        CatchEntry(name: "Rainbow Trout", species: "Oncorhynchus mykiss", weight: "1.8 lb", waterbody: "Willow Creek", lure: "Fly - Adams"),
        CatchEntry(name: "Channel Catfish", species: "Ictalurus punctatus", weight: "6.5 lb", waterbody: "Muddy River", lure: "Cut bait")
        ]
        save()
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    func add(name: String, species: String, weight: String, waterbody: String, lure: String) {
        guard canAddMore else { return }
        let entry = CatchEntry(name: name, species: species, weight: weight, waterbody: waterbody, lure: lure)
        entries.insert(entry, at: 0)
        save()
    }

    func update(_ entry: CatchEntry) {
        if let idx = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[idx] = entry
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: CatchEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([CatchEntry].self, from: data) {
            entries = decoded
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
