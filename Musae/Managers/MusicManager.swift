import Combine
import Foundation
import MediaPlayer

/// Library manager. Loads and updates playlists from the users music library.
class MusicManager: ObservableObject {
    // MARK: - GENERAL
    /// The user's music library.
    @Published var library = MusicLibrary()

    // MARK: - DAILY PLAYLISTS
    /// Daily playlists by category
    @Published var dailyPlaylists: [String: String] = [:]
    /// Date the daily playlists were last updated.
    @Published var dailyPlaylistDate: Date?

    /// Load and update daily playlists
    func loadDailyPlaylists(force: Bool = false) {
        if dailyPlaylistDate == nil || Calendar.current.isDateInToday(dailyPlaylistDate!) == false || force {
            DispatchQueue.global().async { [self] in
                var results: [String: String] = [:]

                for key in library.playlists.keys {
                    /// Results with an average playcount above or equal to 1.
                    let resultsAll: [String] = library.playlists[key, default: []]
                        .sorted(by: {$0.averagePlayCount < $1.averagePlayCount})
                        .map({($0.title)})
                    /// Results with an average playcount below 1.
                    let resultsBelow: [String] = library.playlists[key, default: []]
                        .filter({$0.averagePlayCount < 1})
                        .map({$0.title})

                    if let playlist = resultsBelow.randomElement() {
                        results[key] = playlist
                    } else {
                        switch resultsAll.count {
                        case ...0: results[key] = "Empty category!"
                        case ...4: results[key] = resultsAll[0]
                        case ...8: results[key] = resultsAll[...3].randomElement()!
                        default:   results[key] = resultsAll[...7].randomElement()!
                        }
                    }
                }

                DispatchQueue.main.async {
                    dailyPlaylists = results
                    dailyPlaylistDate = Date()
                }
            }
        }
    }

    // MARK: - TIMERS
    /// Date the timer will fire again.
    @Published var timerNextFireTime: Date?

    /// Timer for refreshing the music library.
    var timer: Timer?

    /// Starts the timer if it is not already running.
    func startTimer() {
        print("Starting timer.")
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                print("Timer triggered: \(Date()).")
                self.library.updateMusic()

                DispatchQueue.main.async {
                    self.timerNextFireTime = self.timer?.fireDate
                }
            }
        }
        timer?.fire()
    }

    /// Stops the timer.
    func stopTimer() {
        print("Stopping timer.")
        timer?.invalidate()
        timer = nil
    }

    // MARK: - INITIALIZATION
    init() {
        startTimer()
    }
}
