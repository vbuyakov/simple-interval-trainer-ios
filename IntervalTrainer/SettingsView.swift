import SwiftUI

struct SettingsView: View {
    @AppStorage("rounds") private var rounds: Int = 6
    @AppStorage("workDuration") private var workDuration: Int = 4
    @AppStorage("restDuration") private var restDuration: Int = 8
    @AppStorage("vibrationEnabled") private var vibrationEnabled: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("workColorName") private var workColorName: String = "red"
    @AppStorage("restColorName") private var restColorName: String = "green"

    let availableColors: [String: Color] = [
        "red": .red,
        "green": .green,
        "blue": .blue,
        "orange": .orange,
        "purple": .purple
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("workout_parameters".localized)) {
                    Stepper("\("rounds".localized): \(rounds)", value: $rounds, in: 1...20)

                    VStack(alignment: .leading) {
                        Text("run_duration".localized)
                        DurationPicker(totalSeconds: $workDuration)
                    }

                    VStack(alignment: .leading) {
                        Text("rest_duration".localized)
                        DurationPicker(totalSeconds: $restDuration)
                    }
                }

                Section(header: Text("colors".localized)) {
                    Picker("work_color".localized, selection: $workColorName) {
                        ForEach(availableColors.keys.sorted(), id: \.self) { key in
                            Text("colors.\(key)".localized).tag(key)
                        }
                    }

                    Picker("rest_color".localized, selection: $restColorName) {
                        ForEach(availableColors.keys.sorted(), id: \.self) { key in
                            Text("colors.\(key)".localized).tag(key)
                        }
                    }
                }

                Section(header: Text("options".localized)) {
                    Toggle("vibration".localized, isOn: $vibrationEnabled)
                    Toggle("sound".localized, isOn: $soundEnabled)
                }

                Section {
                    NavigationLink(destination: WorkoutView(viewModel: IntervalViewModel())) {
                        Text("start_workout".localized)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("intervals".localized)
        }
    }
}

#Preview {
    SettingsView()
}
