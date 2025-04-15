
import SwiftUI

struct SettingsView: View {
    @AppStorage("rounds") private var rounds: Int = 6
    @AppStorage("workDuration") private var workDuration: Int = 4
    @AppStorage("restDuration") private var restDuration: Int = 8
    @AppStorage("workColorHex") private var workColorHex: String = "#FF0000"
    @AppStorage("restColorHex") private var restColorHex: String = "#00FF00"
    @AppStorage("vibrationEnabled") private var vibrationEnabled: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("workVibrationCount") private var workVibrationCount: Int = 1
    @AppStorage("restVibrationCount") private var restVibrationCount: Int = 1

    @State private var workColor: Color = Color.red
    @State private var restColor: Color = Color.green

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
                
                Section {
                    NavigationLink(destination: WorkoutView(viewModel: IntervalViewModel())) {
                        Label("start_workout".localized, systemImage: "figure.run")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(Color(.magenta))
                    }
                }

                Section(header: Text("colors".localized)) {
                    ColorPicker("work_color".localized, selection: $workColor)
                    ColorPicker("rest_color".localized, selection: $restColor)
                }

                Section(header: Text("options".localized)) {
                    Toggle("vibration".localized, isOn: $vibrationEnabled)
                    Toggle("sound".localized, isOn: $soundEnabled)
                }

                if vibrationEnabled {
                    Section {
                        Stepper("work_vibrations".localized + ": \(workVibrationCount)", value: $workVibrationCount, in: 0...10)
                        Stepper("rest_vibrations".localized + ": \(restVibrationCount)", value: $restVibrationCount, in: 0...10)
                    }
                }

                
            }
            .navigationTitle("intervals".localized)
            .onChange(of: rounds) { _ in syncToSharedDefaults() }
            .onChange(of: workDuration) { _ in syncToSharedDefaults() }
            .onChange(of: restDuration) { _ in syncToSharedDefaults() }
            .onChange(of: workColor) { newColor in
                workColorHex = newColor.toHex()
                syncToSharedDefaults()
            }
            .onChange(of: restColor) { newColor in
                restColorHex = newColor.toHex()
                syncToSharedDefaults()
            }
            .onChange(of: workVibrationCount) { _ in syncToSharedDefaults() }
            .onChange(of: restVibrationCount) { _ in syncToSharedDefaults() }
            .onAppear { syncToSharedDefaults() }
        }
    }

    func syncToSharedDefaults() {
        let defaults = UserDefaults(suiteName: "group.pro.sfdp.simpleintervals")
        
        let gRounds = defaults?.integer(forKey: "rounds") ?? 777
        print(gRounds) // Output: "6"
        defaults?.set(rounds, forKey: "rounds")
        
        defaults?.set("sharedValue", forKey: "sharedKey")
        let sharedValue = defaults?.string(forKey: "sharedKey") ?? "No luck"
        print(sharedValue) // Output: "sharedValue"
        
        defaults?.set(workDuration, forKey: "workDuration")
        defaults?.set(restDuration, forKey: "restDuration")
        defaults?.set(workColorHex, forKey: "workColorHex")
        defaults?.set(restColorHex, forKey: "restColorHex")
        defaults?.set(workVibrationCount, forKey: "workVibrationCount")
        defaults?.set(restVibrationCount, forKey: "restVibrationCount")
        defaults?.synchronize()
    }
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

    func toHex() -> String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let r = Int(red * 255)
        let g = Int(green * 255)
        let b = Int(blue * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
