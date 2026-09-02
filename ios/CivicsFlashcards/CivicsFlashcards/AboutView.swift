import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("civics128.appearance") private var appearance = AppearanceSetting.system.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Flashcards for the 2025 naturalization civics test — all 128 official questions and answers for N-400 applications filed on or after October 20, 2025. At the interview, a USCIS officer asks 20 of these questions; answering 12 correctly passes the test.")
                        .font(.callout)
                }

                Section {
                    Picker("Theme", selection: $appearance) {
                        ForEach(AppearanceSetting.allCases) { setting in
                            Text(setting.label).tag(setting.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Appearance")
                } footer: {
                    Text("System follows your device's light/dark setting.")
                }

                Section {
                    Link(destination: AppConfig.officialPDF) {
                        Label("Official USCIS questions & answers (PDF)", systemImage: "doc.text")
                    }
                    Link(destination: AppConfig.testUpdates) {
                        Label("Current officials — uscis.gov/citizenship/testupdates", systemImage: "checkmark.seal")
                    }
                } header: {
                    Text("Data source")
                } footer: {
                    Text("Every question and answer in this app is reproduced from the official USCIS document above, which is also bundled in the app for offline verification. Answers to questions 30, 38, 39, and 57 change with elections or appointments — always verify them shortly before your interview. Questions marked ★ 65/20 are the 20 questions that applicants aged 65 or older with 20 or more years as permanent residents may study exclusively.")
                }

                if let donation = AppConfig.donationURL {
                    Section {
                        Link(destination: donation) {
                            Label("Support the developer", systemImage: "heart")
                        }
                    } footer: {
                        Text("This app is free. If it helped you prepare, an optional donation is appreciated — the link opens in your browser.")
                    }
                }

                Section {
                    Text("Civics 128 is an independent study aid provided for educational purposes only. It is not affiliated with, endorsed by, or connected to U.S. Citizenship and Immigration Services (USCIS) or any other government agency.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("This app does not provide legal or immigration advice. Question and answer text is reproduced from the official USCIS study materials, which are in the public domain, but no guarantee is made that it is accurate, complete, or current. Official answers can change at any time, and the official USCIS materials always take precedence. Always confirm with USCIS before your interview.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("The app is provided \u{201C}as is,\u{201D} without warranties of any kind. The developer is not responsible for test results, immigration outcomes, or any decisions made in reliance on this app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("Your study progress is stored only on this device. The app collects no personal data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Disclaimer")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
