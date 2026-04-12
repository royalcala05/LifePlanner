import SwiftUI

struct SmartInputBarView: View {
    @ObservedObject var viewModel: PlannerViewModel
    @State private var isAddingTag = false

    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.orange)

            TextField("Bench press tomorrow, dinner Friday, buy milk...", text: $viewModel.draftText)
                .textFieldStyle(.plain)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .onSubmit {
                    viewModel.submitDraft()
                }

            Spacer(minLength: 10)

            CategoryBadgeView(
                category: viewModel.selectedCategory,
                customTagName: viewModel.selectedCustomTagName,
                confidenceLabel: viewModel.isUsingManualTag ? "Manual" : (viewModel.selectedCategory == nil ? "Auto-Tag" : viewModel.prediction.confidence.label)
            )
            .frame(width: 240)

            Menu {
                if viewModel.prediction.category != nil {
                    Button("Use Auto-Tag") {
                        viewModel.clearManualTagSelection()
                    }

                    Divider()
                }

                Section("Categories") {
                    ForEach(ReminderCategory.allCases) { category in
                        Button {
                            viewModel.selectCategory(category)
                        } label: {
                            Label(category.displayName, systemImage: category.symbolName)
                        }
                    }
                }

                if viewModel.customTags.isEmpty == false {
                    Section("Custom Tags") {
                        ForEach(viewModel.customTags, id: \.self) { tag in
                            Button {
                                viewModel.selectCustomTag(tag)
                            } label: {
                                Label(tag, systemImage: "tag.fill")
                            }
                        }
                    }

                    Section("Remove Custom Tag") {
                        ForEach(viewModel.customTags, id: \.self) { tag in
                            Button(role: .destructive) {
                                viewModel.removeCustomTag(tag)
                            } label: {
                                Label(tag, systemImage: "trash")
                            }
                        }
                    }
                }
            } label: {
                Label("Choose Tag", systemImage: "tag")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 17, weight: .semibold))
            }
            .menuStyle(.button)
            .help("Choose the tag before saving")

            Button {
                isAddingTag = true
            } label: {
                Image(systemName: "plus")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 17, weight: .semibold))
            }
            .buttonStyle(.bordered)
            .help("Add a custom tag")

            Button {
                viewModel.submitDraft()
            } label: {
                Image(systemName: "return")
                    .font(.system(size: 17, weight: .bold))
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel.canSubmit == false)
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.08), radius: 18, y: 10)
        .overlay(alignment: .bottomLeading) {
            if let latestSaveMessage = viewModel.latestSaveMessage {
                Text(latestSaveMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .offset(x: 58, y: 18)
            }
        }
        .sheet(isPresented: $isAddingTag) {
            AddTagView(
                onAdd: { tag in
                    viewModel.addCustomTag(named: tag)
                    isAddingTag = false
                },
                onCancel: {
                    isAddingTag = false
                }
            )
        }
    }
}

private struct AddTagView: View {
    @State private var tagName = ""

    let onAdd: (String) -> Void
    let onCancel: () -> Void

    private var trimmedTagName: String {
        tagName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Add Tag")
                .font(.system(size: 24, weight: .bold, design: .rounded))

            Text("Create a custom tag you can choose before saving reminders.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Tag name", text: $tagName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 16, weight: .medium))
                .onSubmit {
                    if trimmedTagName.isEmpty == false {
                        onAdd(trimmedTagName)
                    }
                }

            HStack {
                Button("Cancel") {
                    onCancel()
                }

                Spacer()

                Button("Add Tag") {
                    onAdd(trimmedTagName)
                }
                .buttonStyle(.borderedProminent)
                .disabled(trimmedTagName.isEmpty)
            }
        }
        .padding(22)
        .frame(width: 380)
        .background(.regularMaterial)
    }
}
