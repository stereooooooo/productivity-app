import SwiftUI

struct AdvancedFiltersSheet: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var energySelection: Set<String> = []
    @State private var projectSelection: Set<String> = []
    @State private var tagSelection: Set<String> = []
    @State private var newTag: String = ""
    @State private var didLoad = false

    private let energyOptions = ["Low", "Medium", "High"]
    private let projectOptions = ["Work Projects", "Personal", "Learning"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Advanced filters")
                        .font(.title3.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    energySection
                    projectsSection
                    tagsSection
                    prioritySection

                    Spacer(minLength: 0)

                    footer
                }
                .padding(20)
            }
            .background(AppTheme.surface)
        }
        .onAppear { loadStateIfNeeded() }
    }

    private var energySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Energy Level").font(.subheadline.weight(.semibold))
            FlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(energyOptions, id: \.self) { level in
                    Button {
                        toggle(level, in: &energySelection)
                    } label: {
                        Chip(text: level, selected: energySelection.contains(level))
                    }
                }
            }
        }
    }

    private var projectsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Projects").font(.subheadline.weight(.semibold))
            FlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(projectOptions, id: \.self) { project in
                    Button {
                        toggle(project, in: &projectSelection)
                    } label: {
                        SelectableTagPill(text: project, selected: projectSelection.contains(project))
                    }
                }
            }
        }
    }

    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags").font(.subheadline.weight(.semibold))
            FlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(sortedTags, id: \.self) { tag in
                    RemovableTagPill(text: tag) {
                        tagSelection.remove(tag)
                    }
                }
                TextField("Add tag", text: $newTag, onCommit: commitTag)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.surfaceCard)
                    .clipShape(Capsule())
                    .overlay(
                        Capsule().strokeBorder(Color.secondary.opacity(0.3))
                    )
                    .onChange(of: newTag) { _, newValue in
                        guard newValue.contains(",") else { return }
                        let parts = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        parts.forEach(addTagIfNeeded)
                        newTag = ""
                    }
            }
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Priority Only").font(.subheadline.weight(.semibold))
            Toggle("Show only priority tasks", isOn: $store.priorityOnly)
                .toggleStyle(.switch)
        }
    }

    private var footer: some View {
        HStack {
            Button("Reset") { resetFilters() }
                .foregroundStyle(.secondary)
            Spacer()
            Button("Apply") { applyFilters() }
                .buttonStyle(.borderedProminent)
        }
    }

    private var sortedTags: [String] {
        tagSelection.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    private func loadStateIfNeeded() {
        guard !didLoad else { return }
        didLoad = true
        energySelection = store.energy
        projectSelection = store.projects
        tagSelection = store.tags
    }

    private func commitTag() {
        addTagIfNeeded(newTag)
        newTag = ""
    }

    private func addTagIfNeeded(_ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tagSelection.insert(trimmed)
    }

    private func applyFilters() {
        store.energy = energySelection.intersection(Set(energyOptions))
        store.projects = projectSelection
        store.tags = tagSelection
        dismiss()
    }

    private func resetFilters() {
        energySelection.removeAll()
        projectSelection.removeAll()
        tagSelection.removeAll()
        newTag = ""
        store.energy.removeAll()
        store.projects.removeAll()
        store.tags.removeAll()
        store.priorityOnly = false
        dismiss()
    }

    private func toggle(_ item: String, in set: inout Set<String>) {
        if set.contains(item) {
            set.remove(item)
        } else {
            set.insert(item)
        }
    }
}

private struct SelectableTagPill: View {
    var text: String
    var selected: Bool

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundStyle(selected ? .white : .primary)
            .background(selected ? AppTheme.accent : Color.secondary.opacity(0.12))
            .clipShape(Capsule())
            .overlay(
                Capsule().strokeBorder(Color.secondary.opacity(selected ? 0 : 0.3))
            )
    }
}

private struct RemovableTagPill: View {
    var text: String
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text(text).font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(4)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.12))
        .clipShape(Capsule())
    }
}
