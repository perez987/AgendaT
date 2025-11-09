import SwiftUI

enum SortField {
	case name, phone1, phone2, id
}

struct ContentView: View {
	@State private var allEntries: [PhoneEntry] = []
	@State private var filteredEntries: [PhoneEntry] = []
	@State private var searchText: String = ""
	@State private var selectedLetter: String? = nil
	@State private var sortField: SortField = .name
	@State private var sortAscending: Bool = true
	@State private var editingEntry: PhoneEntry?
	@State private var entryToDelete: PhoneEntry?
	@State private var showingDeleteAlert = false
	@State private var showingDuplicateIdAlert = false
	@State private var duplicateIdMessage = ""

		// 26 buttons including K and W (less common starting letters)
	let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }

	var body: some View {
		VStack(spacing: 20) {
				// Title
			Text(localized("phone_numbers"))
				.font(.title)
				.padding(.top)

				// Search and edit controls
			HStack {
				TextField(localized("search_by_name"), text: $searchText)
					.textFieldStyle(RoundedBorderTextFieldStyle())
					.frame(width: 240)

				Button(localized("show_button")) {
					applyFilters()
				}
				.buttonStyle(.borderedProminent)

				Button(localized("clear_filters_button")) {
					clearFilters()
				}
				.buttonStyle(.bordered)
				
				Spacer()
				
				Button(localized("add_contact")) {
					let newId = (allEntries.map { $0.id }.max() ?? 0) + 1
					editingEntry = PhoneEntry(id: newId, name: "", phone1: "", phone2: "")
				}
				.buttonStyle(.borderedProminent)
			}
			.padding(.horizontal)

				// Alphabet buttons (26 letters in 2 rows)
			VStack(spacing: 8) {
				HStack(spacing: 4) {
					ForEach(alphabet.prefix(13), id: \.self) { letter in
						Button(letter) {
							selectedLetter = (selectedLetter == letter) ? nil : letter
							applyFilters()
						}
						.frame(width: 30, height: 30)
						.background(selectedLetter == letter ? Color.accentColor : Color.gray.opacity(0.2))
						.foregroundColor(selectedLetter == letter ? .white : .primary)
						.cornerRadius(5)
					}
				}

				HStack(spacing: 4) {
					ForEach(alphabet.dropFirst(13), id: \.self) { letter in
						Button(letter) {
							selectedLetter = (selectedLetter == letter) ? nil : letter
							applyFilters()
						}
						.frame(width: 30, height: 30)
						.background(selectedLetter == letter ? Color.accentColor : Color.gray.opacity(0.2))
						.foregroundColor(selectedLetter == letter ? .white : .primary)
						.cornerRadius(5)
					}
				}
			}
			.padding(.horizontal)

				// Record count
			Text(String(format: localized("records_shown"), filteredEntries.count))

				.font(.subheadline)
				.foregroundColor(.secondary)

				// Grid view doesn’t support scrolling, can be wrapped inside a ScrollView
				// but can result in performance issues when dataset grows
				// Lazy grid only creates views when they’re about to appear on screen
			ScrollView {
				LazyVGrid(columns: [
//					GridItem(.flexible(minimum: 264)),
					GridItem(.fixed(264)),
					GridItem(.fixed(120)),
					GridItem(.fixed(120)),
					GridItem(.fixed(68))
				], alignment: .leading, spacing: 10) {
						// Header (clickable for sorting)
					Group {
						Button(action: { toggleSort(.name) }) {
							HStack(spacing: 4) {
								Text(localized("header_name"))
									.fontWeight(.bold)
								if sortField == .name {
									Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
										.font(.caption)
								}
							}
						}
						.buttonStyle(.plain)
						.foregroundColor(.primary)
						
						Button(action: { toggleSort(.phone1) }) {
							HStack(spacing: 4) {
								Text(localized("header_phone1"))
									.fontWeight(.bold)
								if sortField == .phone1 {
									Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
										.font(.caption)
								}
							}
						}
						.buttonStyle(.plain)
						.foregroundColor(.primary)
						
						Button(action: { toggleSort(.phone2) }) {
							HStack(spacing: 4) {
								Text(localized("header_phone2"))
									.fontWeight(.bold)
								if sortField == .phone2 {
									Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
										.font(.caption)
								}
							}
						}
						.buttonStyle(.plain)
						.foregroundColor(.primary)
						
						Button(action: { toggleSort(.id) }) {
							HStack(spacing: 4) {
								Text(localized("header_id"))
									.fontWeight(.bold)
								if sortField == .id {
									Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
										.font(.caption)
								}
							}
						}
						.buttonStyle(.plain)
						.foregroundColor(.primary)
					}
					.padding(.vertical, 5)

						// Data rows
					ForEach(filteredEntries) { entry in
						Button(action: {
							editingEntry = entry
						}) {
							Text(entry.name)
								.frame(maxWidth: .infinity, alignment: .leading)
						}
						.buttonStyle(.plain)
						.foregroundColor(.primary)
						
						Text(PhoneEntry.formatPhoneNumber(entry.phone1))
							.frame(maxWidth: .infinity, alignment: .leading)
						Text(PhoneEntry.formatPhoneNumber(entry.phone2))
							.frame(maxWidth: .infinity, alignment: .leading)
						HStack(spacing: 4) {
							Text("\(entry.id)")
								.frame(maxWidth: .infinity, alignment: .leading)
							Button(action: { 
								entryToDelete = entry
								showingDeleteAlert = true
							}) {
								Image(systemName: "trash")
									.foregroundColor(.red)
									.font(.caption)
							}
							.buttonStyle(.plain)
						}
					}
				}
				.padding()
			}
			.frame(maxHeight: .infinity)
			.padding(.leading, 15)
			.padding(.bottom, 15)
			.background(Color.gray.opacity(0.1))
//			.border(Color.secondary, width: 1)
		}
		.frame(minWidth: 660, idealWidth: 660, maxWidth: 660, minHeight: 600)
		.onAppear {
			allEntries = loadPhonebookData()
			filteredEntries = sortEntries(allEntries)
		}
		.sheet(item: $editingEntry) { entry in
			EditContactView(
				entry: entry,
				isNew: !allEntries.contains(where: { $0.id == entry.id }),
				onSave: { updatedEntry in
					saveContact(updatedEntry)
					editingEntry = nil
				},
				onCancel: {
					editingEntry = nil
				}
			)
		}
		.alert(localized("delete_confirmation_title"), isPresented: $showingDeleteAlert) {
			Button(localized("cancel"), role: .cancel) {
				entryToDelete = nil
			}
			Button(localized("delete"), role: .destructive) {
				if let entry = entryToDelete {
					deleteEntry(entry)
				}
				entryToDelete = nil
			}
		} message: {
			if let entry = entryToDelete {
				Text(String(format: localized("delete_confirmation_message"), entry.name))
			}
		}
		.alert(localized("duplicate_id_title"), isPresented: $showingDuplicateIdAlert) {
			Button(localized("ok"), role: .cancel) {}
		} message: {
			Text(duplicateIdMessage)
		}
	}

	private func applyFilters() {
		filteredEntries = FilterSortManager.applyFilters(
			to: allEntries,
			selectedLetter: selectedLetter,
			searchText: searchText,
			sortField: sortField,
			sortAscending: sortAscending
		)
	}
	
	private func toggleSort(_ field: SortField) {
		if sortField == field {
			sortAscending.toggle()
		} else {
			sortField = field
			sortAscending = true
		}
		filteredEntries = FilterSortManager.sortEntries(filteredEntries, by: sortField, ascending: sortAscending)
	}
	
	private func sortEntries(_ entries: [PhoneEntry]) -> [PhoneEntry] {
		return FilterSortManager.sortEntries(entries, by: sortField, ascending: sortAscending)
	}

		// Remove all filters
	private func clearFilters() {
		searchText = ""
		selectedLetter = nil
		filteredEntries = FilterSortManager.sortEntries(allEntries, by: sortField, ascending: sortAscending)
	}
	
	private func saveContact(_ entry: PhoneEntry) {
		if PhonebookManager.saveContact(entry, in: &allEntries) {
			applyFilters()
		}
	}
	
	private func deleteEntry(_ entry: PhoneEntry) {
		if PhonebookManager.deleteEntry(entry, from: &allEntries) {
			applyFilters()
		}
	}
}

#Preview {
	ContentView()
}

struct EditContactView: View {
	@State private var name: String
	@State private var phone1: String
	@State private var phone2: String
	let id: Int
	let isNew: Bool
	let onSave: (PhoneEntry) -> Void
	let onCancel: () -> Void
	@State private var showValidationError = false
	@State private var validationErrorMessage = ""
	
	init(entry: PhoneEntry, isNew: Bool, onSave: @escaping (PhoneEntry) -> Void, onCancel: @escaping () -> Void) {
		_name = State(initialValue: entry.name)
		_phone1 = State(initialValue: entry.phone1)
		_phone2 = State(initialValue: entry.phone2)
		self.id = entry.id
		self.isNew = isNew
		self.onSave = onSave
		self.onCancel = onCancel
	}
	
	var body: some View {
		VStack(spacing: 20) {
			Text(isNew ? localized("add_contact_title") : localized("edit_contact_title"))
				.font(.title)
				.padding(.top)
			
			Form {
                Section() {
					HStack {
						Text(localized("name_label"))
							.frame(width: 80, alignment: .trailing)
						TextField("", text: $name)
                            .frame(width: 220, alignment: .trailing)
							.textFieldStyle(RoundedBorderTextFieldStyle())
					}
					
					HStack {
						Text(localized("phone1_label"))
							.frame(width: 80, alignment: .trailing)
						TextField("", text: $phone1)
                            .frame(width: 180, alignment: .trailing)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.onChange(of: phone1) { newValue in
								phone1 = newValue.filter { $0.isNumber }
							}
					}
					
					HStack {
						Text(localized("phone2_label"))
							.frame(width: 80, alignment: .trailing)
						TextField("", text: $phone2)
                            .frame(width: 180, alignment: .trailing)
							.textFieldStyle(RoundedBorderTextFieldStyle())
							.onChange(of: phone2) { newValue in
								phone2 = newValue.filter { $0.isNumber }
							}
					}
					
					HStack {
						Text(localized("id_label"))
							.frame(width: 80, alignment: .trailing)
						Text("\(id)")
                            .frame(width: 80, alignment: .leading)
							.foregroundColor(.secondary)
					}
				}
			}
			.padding()
			
			HStack(spacing: 20) {
				Button(localized("cancel")) {
					onCancel()
				}
				.buttonStyle(.bordered)
				.keyboardShortcut(.cancelAction)
				
				Button(isNew ? localized("add") : localized("save")) {
						// Phone1 is required
					if phone1.isEmpty {
						validationErrorMessage = localized("phone1_required_error")
						showValidationError = true
						return
					}

						// Validate phone numbers
					if !PhoneEntry.validatePhoneNumber(phone1) {
						validationErrorMessage = localized("invalid_phone_error")
						showValidationError = true
						return
					}

					if !phone2.isEmpty && !PhoneEntry.validatePhoneNumber(phone2) {
						validationErrorMessage = localized("invalid_phone_error")
					}
					
					let entry = PhoneEntry(id: id, name: name, phone1: phone1, phone2: phone2)
					onSave(entry)
				}
				.buttonStyle(.borderedProminent)
				.keyboardShortcut(.defaultAction)
				.disabled(name.isEmpty)
			}
			.padding(.bottom)
		}
		.frame(width: 400, height: 300)
		.alert(localized("validation_error_title"), isPresented: $showValidationError) {
			Button(localized("ok"), role: .cancel) {}
		} message: {
			Text(validationErrorMessage)
		}
	}
}
