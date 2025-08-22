import SwiftUI

public struct FloeSwitch: View {
    @Binding private var isOn: Bool
    private let title: String?
    private let description: String?
    private let accentColor: Color
    private let onChange: ((Bool) -> Void)?
    
    public init(
        _ title: String? = nil,
        description: String? = nil,
        isOn: Binding<Bool>,
        accentColor: Color = FloeColors.primary,
        onChange: ((Bool) -> Void)? = nil
    ) {
        self.title = title
        self.description = description
        self._isOn = isOn
        self.accentColor = accentColor
        self.onChange = onChange
    }
    
    public var body: some View {
        HStack {
            if let title = title {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(FloeColors.neutral10)
                    
                    if let description = description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(FloeColors.neutral40)
                    }
                }
                
                Spacer()
            }
            
            Toggle("", isOn: $isOn)
                .toggleStyle(FloeToggleStyle(accentColor: accentColor))
                .onChange(of: isOn) { newValue in
                    onChange?(newValue)
                }
        }
    }
}

private struct FloeToggleStyle: ToggleStyle {
    let accentColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    configuration.isOn.toggle()
                }
            }) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(configuration.isOn ? accentColor : FloeColors.neutral30)
                    .frame(width: 50, height: 30)
                    .overlay(
                        Circle()
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                            .padding(2)
                            .offset(x: configuration.isOn ? 10 : -10)
                    )
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

public extension FloeSwitch {
    static func basic(isOn: Binding<Bool>) -> FloeSwitch {
        FloeSwitch(isOn: isOn)
    }
}

// MARK: - Previews

#Preview("Basic Switches") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSwitch(isOn: .constant(true))
        FloeSwitch(isOn: .constant(false))
        FloeSwitch.basic(isOn: .constant(true))
    }
    .padding()
}

#Preview("Switches with Labels") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSwitch("Enable Notifications", isOn: .constant(true))
        FloeSwitch("Dark Mode", isOn: .constant(false))
        FloeSwitch("Auto-sync", isOn: .constant(true))
    }
    .padding()
}

#Preview("Switches with Descriptions") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSwitch(
            "Push Notifications",
            description: "Receive alerts about important updates",
            isOn: .constant(true)
        )
        
        FloeSwitch(
            "Face ID",
            description: "Use Face ID to unlock the app",
            isOn: .constant(false)
        )
        
        FloeSwitch(
            "Background Refresh",
            description: "Allow the app to refresh content in the background",
            isOn: .constant(true)
        )
    }
    .padding()
}

#Preview("Custom Colors") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSwitch("Blue Switch", isOn: .constant(true), accentColor: .blue)
        FloeSwitch("Green Switch", isOn: .constant(true), accentColor: .green)
        FloeSwitch("Purple Switch", isOn: .constant(true), accentColor: .purple)
        FloeSwitch("Orange Switch", isOn: .constant(true), accentColor: .orange)
    }
    .padding()
}

#Preview("Settings Screen") {
    VStack(spacing: FloeSpacing.Size.lg.value) {
        Text("Settings")
            .font(.system(size: 28, weight: .bold))
            .frame(maxWidth: .infinity, alignment: .leading)
        
        VStack(spacing: FloeSpacing.Size.md.value) {
            FloeSwitch(
                "Wi-Fi",
                description: "Connect to available networks",
                isOn: .constant(true)
            )
            
            Divider()
            
            FloeSwitch(
                "Bluetooth",
                description: "Connect to nearby devices",
                isOn: .constant(true),
                accentColor: .blue
            )
            
            Divider()
            
            FloeSwitch(
                "Location Services",
                description: "Allow apps to use your location",
                isOn: .constant(false)
            )
            
            Divider()
            
            FloeSwitch(
                "Screen Time",
                description: "Track app usage and set limits",
                isOn: .constant(true),
                accentColor: .purple
            )
        }
    }
    .padding()
}

#Preview("Interactive Switches") {
    struct InteractiveSwitchPreview: View {
        @State private var switch1 = true
        @State private var switch2 = false
        @State private var switch3 = true
        
        var body: some View {
            VStack(spacing: FloeSpacing.Size.md.value) {
                FloeSwitch(
                    "Notifications",
                    isOn: $switch1,
                    onChange: { isOn in
                        print("Notifications: \(isOn)")
                    }
                )
                
                FloeSwitch(
                    "Dark Mode",
                    description: "Toggle between light and dark appearance",
                    isOn: $switch2,
                    accentColor: .indigo,
                    onChange: { isOn in
                        print("Dark Mode: \(isOn)")
                    }
                )
                
                FloeSwitch(
                    "Auto-lock",
                    isOn: $switch3,
                    accentColor: .green,
                    onChange: { isOn in
                        print("Auto-lock: \(isOn)")
                    }
                )
                
                Text("Current States:")
                    .font(.headline)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notifications: \(switch1 ? "On" : "Off")")
                    Text("Dark Mode: \(switch2 ? "On" : "Off")")
                    Text("Auto-lock: \(switch3 ? "On" : "Off")")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
    }
    
    return InteractiveSwitchPreview()
}

#Preview("Dark Mode") {
    VStack(spacing: FloeSpacing.Size.md.value) {
        FloeSwitch("Enable Feature", isOn: .constant(true))
        FloeSwitch("Disable Feature", isOn: .constant(false))
        FloeSwitch(
            "Advanced Setting",
            description: "This setting affects app behavior",
            isOn: .constant(true)
        )
    }
    .padding()
    .preferredColorScheme(.dark)
}