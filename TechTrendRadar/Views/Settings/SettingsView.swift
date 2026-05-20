import SwiftUI

struct SettingsView: View {
    @AppStorage("apiBaseURL") private var savedURL = "https://leaders-button-lexmark-airplane.trycloudflare.com"
    @State private var urlInput = ""
    @State private var showSaved = false
    @State private var testStatus: TestStatus = .idle

    enum TestStatus {
        case idle, loading, ok, fail(String)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.bgBase.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        apiCard
                        currentURLCard
                        appInfoCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear { urlInput = savedURL }
    }

    // MARK: - API Card

    private var apiCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "API Bağlantısı")
            VStack(alignment: .leading, spacing: 8) {
                Text("Backend URL")
                    .font(TTFont.caption)
                    .foregroundStyle(Color.slateMuted)
                urlField
                actionButtons
                statusView
            }
        }
        .padding(16)
        .glassCard()
    }

    private var urlField: some View {
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
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            Button("Kaydet") { saveURL() }
                .buttonStyle(PrimaryButtonStyle())
            Button("Test Et") {
                Task { await testConnection() }
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    @ViewBuilder
    private var statusView: some View {
        if showSaved {
            statusRow(icon: "checkmark.circle.fill", text: "Kaydedildi", color: .positive)
        }
        switch testStatus {
        case .loading:
            HStack(spacing: 6) {
                ProgressView().scaleEffect(0.8)
                Text("Test ediliyor...").font(TTFont.caption).foregroundStyle(Color.slateMuted)
            }
        case .ok:
            statusRow(icon: "checkmark.circle.fill", text: "Bağlantı başarılı", color: .positive)
        case .fail(let msg):
            statusRow(icon: "xmark.circle.fill", text: msg, color: .negative)
        case .idle:
            EmptyView()
        }
    }

    private func statusRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(color)
            Text(text).font(TTFont.caption).foregroundStyle(color)
        }
    }

    // MARK: - Other Cards

    private var currentURLCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Mevcut Bağlantı")
            Text(savedURL)
                .font(TTFont.mono)
                .foregroundStyle(Color.accent)
                .lineLimit(2)
        }
        .padding(16)
        .glassCard()
    }

    private var appInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Uygulama")
            InfoRow(label: "Sürüm",    value: "1.0.0")
            Divider().background(Color.white.opacity(0.05))
            InfoRow(label: "Platform", value: "iOS 17+")
            Divider().background(Color.white.opacity(0.05))
            InfoRow(label: "Kaynak",   value: "HackerNews + yFinance")
        }
        .padding(16)
        .glassCard()
    }

    // MARK: - Actions

    private func saveURL() {
        let trimmed = urlInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        savedURL = trimmed
        testStatus = .idle
        showSaved = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showSaved = false
        }
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
            .font(TTFont.caption).fontWeight(.semibold)
            .foregroundStyle(Color.bgBase)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(Color.accent)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(TTFont.caption).fontWeight(.semibold)
            .foregroundStyle(Color.accent)
            .padding(.horizontal, 20).padding(.vertical, 10)
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
            Text(label).font(TTFont.caption).foregroundStyle(Color.slateMuted)
            Spacer()
            Text(value).font(TTFont.caption).fontWeight(.medium).foregroundStyle(Color.slateText)
        }
        .padding(.vertical, 4)
    }
}
