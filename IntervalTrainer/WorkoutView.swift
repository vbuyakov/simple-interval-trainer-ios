import SwiftUI
import AVFoundation

struct WorkoutView: View {
    @ObservedObject var viewModel: IntervalViewModel

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Round and status
                VStack(spacing: 8) {
                    Text(String(format: NSLocalizedString("round_label", comment: ""), max(viewModel.currentRound, 1), viewModel.settings.rounds))
                        .font(.title2)
                        .foregroundColor(.white)

                    Text(statusText)
                        .font(.title)
                        .foregroundColor(.white)
                }

                // Reset button
                if viewModel.isRunning || viewModel.phase != .finished {
                    Button(action: {
                        viewModel.resetWorkout()
                    }) {
                        Text("reset".localized)
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                }

                // Timer display
                HStack {
                    Spacer()
                    Text(timeString.isEmpty ? "--:--.--" : timeString)
                        .font(.system(size: 55, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                    Spacer()
                }

                // Start / Pause / Finish
                if viewModel.phase != .finished {
                    Button(action: {
                        if viewModel.isRunning {
                            viewModel.pauseWorkout()
                        } else {
                            viewModel.startWorkout()
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 100, height: 100)
                            Image(systemName: viewModel.isRunning ? "pause.fill" : "play.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "trophy.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.orange)

                        Text("🎉")
                            .font(.system(size: 48))

                        Button(action: {
                            viewModel.resetWorkout()
                        }) {
                            Text("finish".localized)
                        }
                        .foregroundColor(.black)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(LocalizedStringKey("workout"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundColor: Color {
        switch viewModel.phase {
        case .work:
            return viewModel.workColor
        case .rest:
            return viewModel.restColor
        case .finished:
            return Color.yellow
        }
    }

    private var timeString: String {
        let totalMilliseconds = Int(viewModel.remainingMilliseconds)
        let ms = (totalMilliseconds % 1000) / 10 // two digits
        let sec = (totalMilliseconds / 1000) % 60
        let min = totalMilliseconds / 60000
        return String(format: "%02d:%02d.%02d", min, sec, ms)
    }

    private var statusText: String {
        switch viewModel.phase {
        case .work: return "interval_run".localized
        case .rest: return "interval_rest".localized
        case .finished: return "interval_done".localized
        }
    }
}
