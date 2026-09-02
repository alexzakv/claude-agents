import SwiftUI

struct DeckView: View {
    @EnvironmentObject private var vm: DeckViewModel
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimatingSwipe = false
    @State private var showResetConfirm = false

    var body: some View {
        VStack(spacing: 16) {
            progressHeader
            cardArea
            controls
        }
        .padding()
        .background(Theme.paper)
        .navigationTitle(deckTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    vm.shuffle()
                } label: {
                    Image(systemName: "shuffle")
                }
                .accessibilityLabel("Shuffle")
                filterMenu
            }
        }
        .confirmationDialog(
            "Clear all known and review marks?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset progress", role: .destructive) { vm.resetProgress() }
        }
    }

    private var deckTitle: String {
        guard let section = vm.sectionFilter else { return "All Questions" }
        return Deck.sectionNames[section].components(separatedBy: " · ").last ?? "Civics 128"
    }

    private var progressHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Text("\(vm.knownCount) of \(vm.totalCount) marked known")
                Spacer()
                Text("\(Int((Double(vm.knownCount) / Double(max(vm.totalCount, 1))) * 100))%")
                    .monospacedDigit()
            }
            .font(.footnote)
            .foregroundStyle(Theme.inkSoft)
            ProgressView(value: Double(vm.knownCount), total: Double(max(vm.totalCount, 1)))
                .tint(Theme.known)
        }
    }

    @ViewBuilder
    private var cardArea: some View {
        if let card = vm.currentCard {
            CardView(
                card: card,
                isKnown: vm.isKnown(card),
                isFlagged: vm.isFlagged(card),
                isFlipped: $vm.isFlipped
            )
            .offset(x: dragOffset)
            .rotationEffect(.degrees(Double(dragOffset) / 40))
            .opacity(1 - min(abs(dragOffset) / 600, 0.6))
            .gesture(swipeGesture)
            .frame(maxHeight: .infinity)
        } else {
            ContentUnavailableCompat(dataMissing: vm.totalCount == 0)
                .frame(maxHeight: .infinity)
        }
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                guard !isAnimatingSwipe else { return }
                if abs(value.translation.width) > abs(value.translation.height) {
                    dragOffset = value.translation.width
                }
            }
            .onEnded { value in
                guard !isAnimatingSwipe else { return }
                let threshold: CGFloat = 90
                if dragOffset < -threshold {
                    animateSwipe(direction: -1) { vm.next() }
                } else if dragOffset > threshold {
                    animateSwipe(direction: 1) { vm.previous() }
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func animateSwipe(direction: CGFloat, then advance: @escaping () -> Void) {
        isAnimatingSwipe = true
        withAnimation(.easeIn(duration: 0.18)) {
            dragOffset = direction * (UIScreen.main.bounds.width + 120)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) {
            advance()
            dragOffset = 0
            isAnimatingSwipe = false
        }
    }

    private var controls: some View {
        VStack(spacing: 10) {
            if !vm.deck.isEmpty {
                Text("Card \(vm.position + 1) of \(vm.deck.count)")
                    .font(.caption)
                    .foregroundStyle(Theme.inkFaint)
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                Button {
                    animateSwipe(direction: 1) { vm.previous() }
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)

                Button {
                    vm.isFlipped.toggle()
                } label: {
                    Label("Flip", systemImage: "arrow.triangle.2.circlepath")
                        .frame(minWidth: 80)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    animateSwipe(direction: -1) { vm.next() }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .buttonStyle(.bordered)
            }
            HStack(spacing: 10) {
                Button {
                    vm.toggleKnown()
                } label: {
                    Label("I know this", systemImage: "checkmark")
                }
                .buttonStyle(.bordered)
                .tint(vm.currentCard.map(vm.isKnown) == true ? Theme.known : nil)

                Button {
                    vm.toggleFlagged()
                } label: {
                    Label("Review again", systemImage: "flag")
                }
                .buttonStyle(.bordered)
                .tint(vm.currentCard.map(vm.isFlagged) == true ? Theme.flag : nil)
            }
        }
        .disabled(vm.deck.isEmpty)
    }

    private var filterMenu: some View {
        Menu {
            Picker("Section", selection: $vm.sectionFilter) {
                Text("All sections").tag(Int?.none)
                ForEach(Deck.sectionNames.indices, id: \.self) { index in
                    Text(Deck.sectionNames[index]).tag(Int?.some(index))
                }
            }
            Toggle("Hide known", isOn: $vm.hideKnown)
            Toggle("Flagged only", isOn: $vm.flaggedOnly)
            Divider()
            Button {
                vm.shuffle()
            } label: {
                Label("Shuffle", systemImage: "shuffle")
            }
            Button(role: .destructive) {
                showResetConfirm = true
            } label: {
                Label("Reset progress", systemImage: "trash")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
        .accessibilityLabel("Filters and options")
    }
}

/// Custom empty state styled to match the app theme.
private struct ContentUnavailableCompat: View {
    var dataMissing = false

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: dataMissing ? "exclamationmark.triangle" : "rectangle.on.rectangle.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(dataMissing ? "The question data could not be loaded" : "No cards match these filters")
                .font(.headline)
            Text(dataMissing ? "Please delete and reinstall the app." : "Change the section filter or turn off “Hide known” / “Flagged only”.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    NavigationStack { DeckView() }
        .environmentObject(DeckViewModel())
}
