import Foundation
import Combine
import AVFoundation
import SwiftUI
import UIKit

class IntervalViewModel: ObservableObject {
    enum Phase {
        case work, rest, finished
    }

    // Сохраняемые параметры
    @AppStorage("vibrationEnabled") private var storedVibrationEnabled: Bool = true
    @AppStorage("soundEnabled") private var storedSoundEnabled: Bool = true
    @AppStorage("workColorName") private var storedWorkColorName: String = "red"
    @AppStorage("restColorName") private var storedRestColorName: String = "green"

    // Публичные параметры
    @Published var settings: IntervalSettings
    @Published var currentRound = 0
    @Published var phase: Phase = .work
    @Published var isRunning = false
    @Published var remainingMilliseconds: Double = 0
    @Published var workColorName: String
    @Published var restColorName: String

    var vibrationEnabled: Bool { storedVibrationEnabled }
    var soundEnabled: Bool { storedSoundEnabled }
    var workColor: Color { Color(workColorName) }
    var restColor: Color { Color(restColorName) }

    private var timer: Timer?

    init() {
        let rounds = UserDefaults.standard.integer(forKey: "rounds")
        let work = UserDefaults.standard.integer(forKey: "workDuration")
        let rest = UserDefaults.standard.integer(forKey: "restDuration")
        let workColor = UserDefaults.standard.string(forKey: "workColorName") ?? "red"
        let restColor = UserDefaults.standard.string(forKey: "restColorName") ?? "green"

        self.settings = IntervalSettings(
            rounds: rounds > 0 ? rounds : 6,
            workDuration: work > 0 ? work : 4,
            restDuration: rest > 0 ? rest : 8
        )

        self.workColorName = workColor
        self.restColorName = restColor
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
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
