import SwiftUI
import PDFKit

/// Shows the bundled official USCIS document, opened at a specific page.
struct SourceViewer: View {
    let page: Int
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if let url = Deck.bundledPDF {
                    PDFKitView(url: url, page: page)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    Text("The bundled document could not be loaded.")
                        .foregroundStyle(Theme.inkSoft)
                }
            }
            .navigationTitle("Official USCIS Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Link(destination: AppConfig.officialPDF) {
                        Label("uscis.gov", systemImage: "safari")
                    }
                    .accessibilityLabel("Open at uscis.gov")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct PDFKitView: UIViewRepresentable {
    let url: URL
    let page: Int

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.backgroundColor = .secondarySystemBackground
        if let document = PDFDocument(url: url) {
            view.document = document
            if let target = document.page(at: page) {
                DispatchQueue.main.async { view.go(to: target) }
            }
        }
        return view
    }

    func updateUIView(_ view: PDFView, context: Context) {}
}
