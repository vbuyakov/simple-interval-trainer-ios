
import SwiftUI
import WatchKit

struct WatchContentView: View {
    @StateObject private var viewModel = IntervalWatchViewModel()

    var body: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)

            if viewModel.phase == .finished {
                VStack(spacing: 12) {
                    Text("🏆")
                        .font(.system(size: 48))
                    Text("Well done!")
                        .font(.title3)
                        .foregroundColor(.black)
                    Button(action: viewModel.reset) {
                        Text("Restart")
                            .font(.headline)
                            .padding()
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    HStack {
                        Text("Round \(viewModel.currentRound) of \(viewModel.totalRounds)")
                            .font(.footnote)
                        Spacer()
                        Button(action: { viewModel.reset() }) {
                                                Image(systemName: "arrow.counterclockwise")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                    .frame(width: 20, height: 20)
                                            }
                                            .buttonStyle(.plain)
                        }

                    Text(viewModel.timeString)
                                       .font(.system(size: 28, weight: .bold, design: .monospaced))
                                       .frame(maxWidth: .infinity, alignment: .center)
                                       .padding(.vertical, 4)

                    Button(action: {
                                        viewModel.isRunning ? viewModel.pause() : viewModel.start()
                                    }) {
                                        Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                    }
                }
                .padding()
            }
        }
    }

    private var backgroundColor: Color {
        switch viewModel.phase {
        case .work: return viewModel.workColor
        case .rest: return viewModel.restColor
        case .finished: return .yellow
        }
    }

    
}
