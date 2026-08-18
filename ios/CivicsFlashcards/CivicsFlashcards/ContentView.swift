import SwiftUI

struct ContentView: View {
    @StateObject private var vm = DeckViewModel()
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimatingSwipe = false
    @State private var showAbout = false
    @State private var showResetConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                progressHeader
                cardArea
                controls
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Civics 128")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    filterMenu
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAbout = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("About and sources")
                }
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .confirmationDialog(
                "Clear all known and review marks?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Reset progress", role: .destructive) { vm.resetProgress() }
            }
        }
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
            .foregroundStyle(.secondary)
            ProgressView(value: Double(vm.knownCount), total: Double(max(vm.totalCount, 1)))
                .tint(.green)
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
            ContentUnavailableCompat()
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
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                Button {
                    animateSwipe(direction: 1) { vm.previous() }
                } label: {
                    Label("Back", systemImage: "chevron.left")
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
                .tint(vm.currentCard.map(vm.isKnown) == true ? .green : nil)

                Button {
                    vm.toggleFlagged()
                } label: {
                    Label("Review again", systemImage: "flag")
                }
                .buttonStyle(.bordered)
                .tint(vm.currentCard.map(vm.isFlagged) == true ? .red : nil)
            }
        }
        .disabled(vm.deck.isEmpty && vm.currentCard == nil)
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

/// Empty-state view (avoids the iOS 17-only ContentUnavailableView).
private struct ContentUnavailableCompat: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "rectangle.on.rectangle.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("No cards match these filters")
                .font(.headline)
            Text("Change the section filter or turn off “Hide known” / “Flagged only”.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
