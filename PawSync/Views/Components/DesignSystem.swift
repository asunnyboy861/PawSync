import SwiftUI
import SwiftData

enum PawSyncTheme {
    static let accent = Color(hex: "4A7C59")
    static let accentLight = Color(hex: "6B9F7B")
    static let accentGradient = LinearGradient(
        colors: [Color(hex: "4A7C59"), Color(hex: "6B9F7B")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let warmGradient = LinearGradient(
        colors: [Color(hex: "E8985E"), Color(hex: "F0B87A")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let purpleGradient = LinearGradient(
        colors: [Color(hex: "7B2FBE"), Color(hex: "C56CD6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "F7971E"), Color(hex: "FFD200")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let heroGradient = LinearGradient(
        colors: [Color(hex: "4A7C59"), Color(hex: "6B9F7B"), Color(hex: "8FC4A0")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardBackground = Color(.systemBackground)
    static let subtleBackground = Color(.systemGray6).opacity(0.5)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 16
    var shadowOpacity: Double = 0.08

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(shadowOpacity), radius: 12, y: 4)
            )
    }
}

struct ElevatedCard: ViewModifier {
    var cornerRadius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.02), radius: 2, x: 0, y: 1)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }

    func elevatedCard(cornerRadius: CGFloat = 16) -> some View {
        modifier(ElevatedCard(cornerRadius: cornerRadius))
    }
}

struct StaggeredAppear: ViewModifier {
    let index: Int
    let animation: Animation
    @State private var isVisible = false

    init(index: Int, baseDelay: Double = 0.05) {
        self.index = index
        self.animation = .spring(response: 0.5, dampingFraction: 0.8)
            .delay(Double(index) * baseDelay)
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(animation) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggeredAppear(index: Int, baseDelay: Double = 0.05) -> some View {
        modifier(StaggeredAppear(index: index, baseDelay: baseDelay))
    }
}

struct AnimatedProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    let gradient: LinearGradient
    @State private var animatedProgress: Double = 0

    init(progress: Double, lineWidth: CGFloat = 6, size: CGFloat = 60, gradient: LinearGradient = PawSyncTheme.accentGradient) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
        self.gradient = gradient
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(gradient, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7).delay(0.2)) {
                animatedProgress = min(progress, 1.0)
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animatedProgress = min(newValue, 1.0)
            }
        }
    }
}

struct BounceButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GradientIconBadge: View {
    let icon: String
    let gradient: LinearGradient
    var size: CGFloat = 44
    var iconFont: Font = .body

    var body: some View {
        Image(systemName: icon)
            .font(iconFont)
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.28))
    }
}

struct SectionHeader: View {
    let title: String
    var icon: String? = nil
    var trailing: String? = nil

    var body: some View {
        HStack {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(PawSyncTheme.accent)
                    .font(.subheadline.weight(.semibold))
            }
            Text(title)
                .font(.title3.weight(.bold))
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(PawSyncTheme.accent.opacity(0.08))
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.05 : 1)

                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundStyle(PawSyncTheme.accent.opacity(0.6))
                    .symbolEffect(.pulse.wholeSymbol, options: .repeating)
            }

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(PawSyncTheme.accentGradient)
                        .clipShape(Capsule())
                }
                .buttonStyle(BounceButtonStyle())
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct GradientButton: View {
    let title: String
    var icon: String? = nil
    var gradient: LinearGradient = PawSyncTheme.accentGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: PawSyncTheme.accent.opacity(0.3), radius: 8, y: 4)
        }
        .buttonStyle(BounceButtonStyle())
    }
}

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func heavy() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }
}

struct PetPickerView: View {
    @Binding var selectedPet: Pet?
    @Query private var pets: [Pet]

    init(selectedPet: Binding<Pet?>) {
        self._selectedPet = selectedPet
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(pets) { pet in
                    PetChip(pet: pet, isSelected: selectedPet?.id == pet.id) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedPet = pet
                        }
                        Haptics.selection()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PetChip: View {
    let pet: Pet
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(.white, lineWidth: 1.5))
                } else {
                    Image(systemName: pet.species.icon)
                        .font(.caption)
                        .foregroundStyle(isSelected ? .white : PawSyncTheme.accent)
                        .frame(width: 32, height: 32)
                        .background(isSelected ? PawSyncTheme.accent.opacity(0.2) : Color(.systemGray6))
                        .clipShape(Circle())
                }

                Text(pet.name)
                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? PawSyncTheme.accent : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? PawSyncTheme.accent.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        Capsule()
                            .stroke(isSelected ? PawSyncTheme.accent : Color.clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
