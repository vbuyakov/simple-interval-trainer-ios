import SwiftUI
import AVFoundation

struct WorkoutView: View {
    @ObservedObject var viewModel: IntervalViewModel

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Раунд + статус
                VStack(spacing: 8) {
                    Text(String(format: NSLocalizedString("round_label", comment: ""), max(viewModel.currentRound, 1), viewModel.settings.rounds))
                        .font(.title2)
                        .foregroundColor(.white)

                    Text(statusText)
                        .font(.title)
                        .foregroundColor(.white)
                }

                // Reset кнопка
                if viewModel.isRunning || viewModel.phase != .finished {
                    Button(action: {
                        viewModel.resetWorkout()
                    }) {
                        Text("reset".localized)
                    }
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                }

                // Таймер
                HStack {
                    Spacer()
                    Text(timeString)
                        .foregroundColor(.black)
                        .font(.system(size: 55, weight: .bold, design: .monospaced))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                    Spacer()
                }

                // Старт / Пауза / Завершить
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
                            Text(LocalizedStringKey("finish"))
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
            return Color.named(viewModel.workColorName)
        case .rest:
            return Color.named(viewModel.restColorName)
        case .finished:
            return Color.yellow
        }
    }

    private var timeString: String {
    let totalMilliseconds = Int(viewModel.remainingMilliseconds)
    let ms = (totalMilliseconds % 1000) / 10 // две цифры
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

extension Color {
    static func named(_ name: String) -> Color {
        switch name.lowercased() {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        default: return .gray
        }
    }
}
