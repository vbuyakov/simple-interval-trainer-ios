import Foundation
import Combine
import AVFoundation
import SwiftUI
import UIKit

class IntervalViewModel: ObservableObject {
    enum Phase {
        case work, rest, finished
    }

    // Stored preferences
    @AppStorage("vibrationEnabled") private var storedVibrationEnabled: Bool = true
    @AppStorage("soundEnabled") private var storedSoundEnabled: Bool = true
    @AppStorage("workColorHex") private var storedWorkColorHex: String = "#FF0000"
    @AppStorage("restColorHex") private var storedRestColorHex: String = "#00FF00"
    @AppStorage("workVibrationCount") private var storedWorkVibrationCount: Int = 1
    @AppStorage("restVibrationCount") private var storedRestVibrationCount: Int = 1

    // Public state
    @Published var settings: IntervalSettings
    @Published var currentRound = 0
    @Published var phase: Phase = .work
    @Published var isRunning = false
    @Published var remainingMilliseconds: Double = 0

    var vibrationEnabled: Bool { storedVibrationEnabled }
    var soundEnabled: Bool { storedSoundEnabled }
    var workColor: Color { Color(hex: storedWorkColorHex) }
    var restColor: Color { Color(hex: storedRestColorHex) }
    var workVibrationCount: Int { storedWorkVibrationCount }
    var restVibrationCount: Int { storedRestVibrationCount }

    private var timer: Timer?

    init() {
        let rounds = UserDefaults.standard.integer(forKey: "rounds")
        let work = UserDefaults.standard.integer(forKey: "workDuration")
        let rest = UserDefaults.standard.integer(forKey: "restDuration")

        self.settings = IntervalSettings(
            rounds: rounds > 0 ? rounds : 6,
            workDuration: work > 0 ? work : 4,
            restDuration: rest > 0 ? rest : 8
        )

        self.remainingMilliseconds = Double(self.settings.workDuration) * 1000
    }

    func startWorkout() {
        if currentRound == 0 {
            currentRound = 1
            phase = .work
            remainingMilliseconds = Double(settings.workDuration) * 1000
        }
        isRunning = true
        runTimer()
    }

    func pauseWorkout() {
        timer?.invalidate()
        isRunning = false
    }

    func resetWorkout() {
        timer?.invalidate()
        isRunning = false
        currentRound = 0
        remainingMilliseconds = Double(settings.workDuration) * 1000
        phase = .work
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
            playSound(for: .rest)
            phase = .rest
            remainingMilliseconds = Double(settings.restDuration) * 1000
            runTimer()
        case .rest:
            if currentRound < settings.rounds {
                currentRound += 1
                playSound(for: .work)
                phase = .work
                remainingMilliseconds = Double(settings.workDuration) * 1000
                runTimer()
            } else {
                playSound(for: .finished)
                phase = .finished
                isRunning = false
                timer?.invalidate()
            }
        case .finished:
            break
        }
    }

    private func playSound(for phase: Phase) {
        guard soundEnabled || vibrationEnabled else { return }

        let soundID: SystemSoundID
        switch phase {
        case .work:
            soundID = 1001
        case .rest:
            soundID = 1005
        case .finished:
            soundID = 1057
        }

        if soundEnabled {
            AudioServicesPlaySystemSound(soundID)
        }
        if vibrationEnabled {
            let count = phase == .work ? workVibrationCount
                : phase == .rest ? restVibrationCount
                : 1
            vibrate(repeats: count)
        }
    }
    
    private func vibrate(repeats: Int) {
        guard repeats > 0 else { return }
        
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.vibrate(repeats: repeats - 1)
        }
    }
}
