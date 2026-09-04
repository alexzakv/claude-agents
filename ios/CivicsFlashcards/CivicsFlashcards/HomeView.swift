import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var vm: DeckViewModel
    @AppStorage("civics128.welcomed") private var welcomed = false
    @State private var path = NavigationPath()
    @State private var showWelcome = false
    @State private var showAbout = false
    @State private var didHandleLaunch = false

    var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    if vm.totalCount == 0 {
                        Text("The question data could not be loaded. Please delete and reinstall the app.")
                            .font(.callout)
                            .foregroundStyle(Theme.flag)
                    } else {
                        continueCard
                        sectionList
                    }
                }
                .padding()
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.paper)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About and sources")
                }
            }
            .navigationDestination(for: String.self) { _ in
                DeckView()
            }
            .sheet(isPresented: $showAbout) { AboutView() }
            .sheet(isPresented: $showWelcome) {
                WelcomeView {
                    welcomed = true
                    showWelcome = false
                }
                .interactiveDismissDisabled()
            }
            .onAppear(perform: onLaunch)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("U.S. Citizenship Test · 2026")
                .font(.caption)
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(Theme.inkFaint)
            Text("Civics 128")
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .foregroundStyle(Theme.ink)
            Text("All 128 official questions and answers. The officer asks 20; answer 12 correctly to pass.")
                .font(.subheadline)
                .foregroundStyle(Theme.inkSoft)
        }
    }

    private var continueCard: some View {
        Button {
            vm.sectionFilter = nil
            path.append("deck")
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Study All 128 Questions")
                        .font(.headline)
                    Text("\(vm.knownCount) of \(vm.totalCount) marked known")
                        .font(.caption)
                        .opacity(0.85)
                }
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
            .foregroundStyle(Theme.accentInkColor)
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Theme.accent, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Study All Questions")
    }

    private var sectionList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Sections")
                .font(.caption)
                .textCase(.uppercase)
                .kerning(1.2)
                .foregroundStyle(Theme.inkFaint)
            ForEach(Deck.sectionNames.indices, id: \.self) { index in
                sectionRow(index)
            }
        }
    }

    private func sectionRow(_ index: Int) -> some View {
        let parts = Deck.sectionNames[index].components(separatedBy: " · ")
        let counts = vm.sectionCounts(index)
        let fraction = counts.total > 0 ? Double(counts.known) / Double(counts.total) : 0
        return Button {
            vm.sectionFilter = index
            path.append("deck")
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(parts.first ?? "")
                            .font(.caption2)
                            .textCase(.uppercase)
                            .kerning(0.8)
                            .foregroundStyle(Theme.inkFaint)
                        Text(parts.count > 1 ? parts[1] : Deck.sectionNames[index])
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Theme.ink)
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                    Text("\(counts.known)/\(counts.total)")
                        .font(.caption)
                        .monospacedDigit()
                        .foregroundStyle(counts.total > 0 && counts.known == counts.total ? Theme.known : Theme.inkSoft)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Theme.line)
                        Capsule().fill(Theme.known)
                            .frame(width: max(geo.size.width * fraction, fraction > 0 ? 6 : 0))
                    }
                }
                .frame(height: 5)
            }
            .padding(14)
            .background(Theme.card, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Theme.line)
            )
        }
        .buttonStyle(.plain)
    }

    // First launch shows the welcome once; screenshot automation bypasses it.
    private func onLaunch() {
        guard !didHandleLaunch else { return }
        didHandleLaunch = true
        let args = ProcessInfo.processInfo.arguments
        #if DEBUG
        let automation = args.contains("-uiFlipped") || args.contains("-uiCard") || args.contains("-uiAbout") || args.contains("-uiDeck")
        if args.contains("-uiWelcome") {
            showWelcome = true
            return
        }
        if automation {
            welcomed = true
            if args.contains("-uiAbout") {
                showAbout = true
                return
            }
            vm.sectionFilter = nil
            if let i = args.firstIndex(of: "-uiCard"), args.indices.contains(i + 1), let id = Int(args[i + 1]) {
                vm.jump(toId: id)
            }
            if args.contains("-uiFlipped") { vm.isFlipped = true }
            if path.isEmpty { path.append("deck") }
            return
        }
        #endif
        if !welcomed { showWelcome = true }
    }
}

#Preview {
    HomeView().environmentObject(DeckViewModel())
}
