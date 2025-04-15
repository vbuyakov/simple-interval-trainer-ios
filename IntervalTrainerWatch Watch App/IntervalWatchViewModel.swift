
import Foundation
import SwiftUI
import Combine
import WatchKit

class IntervalWatchViewModel: ObservableObject {
    enum Phase {
        case work, rest, finished
    }

    @Published var currentRound: Int = 0
    @Published var isRunning: Bool = false
    @Published var remainingMilliseconds: Double = 0
    @Published var phase: Phase = .work
    @Published var workColorHex: String = "#FF0000"
    @Published var restColorHex: String = "#00FF00"

    var workColor: Color { Color(hex: workColorHex) }
    var restColor: Color { Color(hex: restColorHex) }

    private var timer: Timer?
    private var settings: IntervalSettings = .default
    private var workVibrationCount: Int = 2
    private var restVibrationCount: Int = 4

    init() {
        loadSettings()
    }

    func loadSettings() {
        let defaults = UserDefaults(suiteName: "group.pro.sfdp.simpleintervals")
        defaults?.synchronize()
        let rounds = 4 // defaults?.integer(forKey: "rounds") ?? 6
        let work = 5 //defaults?.integer(forKey: "workDuration") ?? 4
        let rest = 10 //defaults?.integer(forKey: "restDuration") ?? 8
        let restVibrationCount = 2 //defaults?.integer(forKey: "restVibrationCount") ?? 1
        let workVibrationCount = 4 //defaults?.integer(forKey: "workVibrationCount") ?? 1
        let workHex = defaults?.string(forKey: "workColorHex") ?? "#FF0000"
        let restHex = defaults?.string(forKey: "restColorHex") ?? "#00FF00"

        self.settings = IntervalSettings(rounds: rounds, workDuration: work, restDuration: rest)
        self.restVibrationCount = restVibrationCount
        self.workVibrationCount = workVibrationCount
        self.workColorHex = workHex
        self.restColorHex = restHex
        self.remainingMilliseconds = Double(work) * 1000
    }

    func start() {
        if currentRound == 0 {
            currentRound = 1
            phase = .work
            remainingMilliseconds = Double(settings.workDuration) * 1000
        }
        isRunning = true
        runTimer()
    }

    func pause() {
        timer?.invalidate()
        isRunning = false
    }

    func reset() {
        loadSettings()
        timer?.invalidate()
        currentRound = 0
        phase = .work
        remainingMilliseconds = Double(settings.workDuration) * 1000
        isRunning = false
    }

    private func runTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            DispatchQueue.main.async {
                guard self.remainingMilliseconds > 0 else {
                    self.advancePhase()
                    return
                }
                self.remainingMilliseconds -= 10
            }
        }
    }

    private func advancePhase() {
        switch phase {
        case .work:
            vibrate(repeats: workVibrationCount)
            phase = .rest
            remainingMilliseconds = Double(settings.restDuration) * 1000
            runTimer()
        case .rest:
            if currentRound < settings.rounds {
                currentRound += 1
                vibrate(repeats: restVibrationCount)
                phase = .work
                remainingMilliseconds = Double(settings.workDuration) * 1000
                runTimer()
            } else {
                phase = .finished
                isRunning = false
                timer?.invalidate()
                vibrate(repeats: 5)
            }
        case .finished:
            break
        }
    }

    
    private func vibrate(repeats: Int) {
        guard repeats > 0 else { return }
        
        DispatchQueue.main.async {
            WKInterfaceDevice.current().play(.success)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.vibrate(repeats: repeats - 1)
        }
    }

    var timeString: String {
        let totalMs = Int(remainingMilliseconds)
        let minutes = totalMs / 60000
        let seconds = (totalMs / 1000) % 60
        let ms = (totalMs / 10) % 100
        return String(format: "%02d:%02d.%02d", minutes, seconds, ms)
    }

    var totalRounds: Int {
        settings.rounds
    }
}

struct IntervalSettings {
    var rounds: Int
    var workDuration: Int
    var restDuration: Int

    static let `default` = IntervalSettings(rounds: 6, workDuration: 4, restDuration: 8)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (255, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
