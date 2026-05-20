import SwiftUI

struct SettingsView: View {
    @AppStorage("apiBaseURL") private var apiBaseURL = "https://leaders-button-lexmark-airplane.trycloudflare.com"
    @State private var urlInput = ""
    @State private var showSaved = false
    @State private var testStatus: TestStatus = .idle

    enum TestStatus { case idle, loading, ok, fail(String) }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // API URL card
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "API Bağlantısı")

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Backend URL")
                                    .font(TTFont.caption)
                                    .foregroundStyle(Color.slateMuted)

                                TextField("https://...", text: $urlInput)
                                    .font(TTFont.mono)
                                    .foregroundStyle(Color.slateText)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.URL)
                                    .padding(12)
                                    .background(Color.bgSurface)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                                    )

                                HStack(spacing: 10) {
                                    Button("Kaydet") {
                                        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
                                        guard !trimmed.isEmpty else { return }
                                        apiBaseURL = trimmed
                                        showSaved = true
                                        testStatus = .idle
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            showSaved = false
                                        }
                                    }
                                    .buttonStyle(PrimaryButtonStyle())

                                    Button("Test Et") {
                                        Task { await testConnection() }
                                    }
                                    .buttonStyle(SecondaryButtonStyle())
                                }

                                // Status indicators
                                if showSaved {
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.positive)
                                        Text("Kaydedildi")
                                            .font(TTFont.caption)
                                            .foregroundStyle(Color.positive)
                                    }
                                }

                                switch testStatus {
                                case .loading:
                                    HStack(spacing: 6) {
                                        ProgressView().scaleEffect(0.8)
                                        Text("Test ediliyor...")
                                            .font(TTFont.caption)
                                            .foregroundStyle(Color.slateMuted)
                                    }
                                case .ok:
                                    HStack(spacing: 6) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.positive)
                                        Text("Bağlantı başarılı")
                                            .font(TTFont.caption)
                                            .foregroundStyle(Color.positive)
                                    }
                                case .fail(let msg):
                                    HStack(spacing: 6) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.negative)
                                        Text(msg)
                                            .font(TTFont.caption)
                                            .foregroundStyle(Color.negative)
                                    }
                                case .idle:
                                    EmptyView()
                                }
                            }
                        }
                        .padding(16)
                        .glassCard()

                        // Current URL info
                        VStack(alignment: .leading, spacing: 8) {
                            SectionHeader(title: "Mevcut Bağlantı")
                            Text(apiBaseURL)
                                .font(TTFont.mono)
                                .foregroundStyle(Color.accent)
                                .lineLimit(2)
                        }
                        .padding(16)
                        .glassCard()

                        // App info
                        VStack(alignment: .leading, spacing: 12) {
                            SectionHeader(title: "Uygulama")

                            InfoRow(label: "Sürüm",   value: "1.0.0")
                            Divider().background(Color.white.opacity(0.05))
                            InfoRow(label: "Platform", value: "iOS 17+")
                            Divider().background(Color.white.opacity(0.05))
                            InfoRow(label: "Kaynak",   value: "HackerNews + yFinance")
                        }
                        .padding(16)
                        .glassCard()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { urlInput = apiBaseURL }
    }

    private func testConnection() async {
        testStatus = .loading
        let url = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let u = URL(string: url + "/health/") else {
            testStatus = .fail("Geçersiz URL")
            return
        }
        do {
            let (_, response) = try await URLSession.shared.data(from: u)
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) {
                testStatus = .ok
            } else {
                testStatus = .fail("Sunucu yanıt vermedi")
            }
        } catch {
            testStatus = .fail(error.localizedDescription)
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.bgBase)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.accent)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.caption)
            .fontWeight(.semibold)
            .foregroundStyle(Color.accent)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.accent.opacity(0.12))
            .overlay(Capsule().strokeBorder(Color.accent.opacity(0.3), lineWidth: 1))
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Info Row

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(TTFont.caption)
                .foregroundStyle(Color.slateMuted)
            Spacer()
            Text(value)
                .font(TTFont.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.slateText)
        }
        .padding(.vertical, 4)
    }
}
