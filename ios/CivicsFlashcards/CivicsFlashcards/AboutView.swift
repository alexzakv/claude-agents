import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Flashcards for the 2025 naturalization civics test — all 128 official questions and answers for N-400 applications filed on or after October 20, 2025. At the interview, a USCIS officer asks 20 of these questions; answering 12 correctly passes the test.")
                        .font(.callout)
                }

                Section("Verify at the source") {
                    Link(destination: AppConfig.officialPDF) {
                        Label("Official USCIS questions & answers (PDF)", systemImage: "doc.text")
                    }
                    Link(destination: AppConfig.testUpdates) {
                        Label("Current officials — uscis.gov/citizenship/testupdates", systemImage: "checkmark.seal")
                    }
                } footer: {
                    Text("Answers to questions 24, 30, 38, 39, 53, and 57 can change because of elections or appointments. Always verify them shortly before your interview.")
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
                    Text("This app is an independent study aid. It is not affiliated with, endorsed by, or connected to USCIS or any government agency. Question and answer text is reproduced from the official USCIS study materials, which are in the public domain.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text("Your study progress is stored only on this device. The app collects no personal data.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
