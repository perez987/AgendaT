import Foundation

/// Manages CRUD (create, read, update, delete) operations for phonebook entries
class PhonebookManager {
	/// Saves or updates a contact in the phonebook
	/// - Parameters:
	///   - entry: The phone entry to save
	///   - allEntries: The current array of all entries
	/// - Returns: true if the contact was successfully saved, false otherwise
	static func saveContact(_ entry: PhoneEntry, in allEntries: inout [PhoneEntry]) -> Bool {
		// Find if this entry already exists in our list
		let existingIndex = allEntries.firstIndex(where: { $0.id == entry.id })
		
		if existingIndex == nil {
			// New contact
			allEntries.append(entry)
		} else {
			// Updating existing contact
			allEntries[existingIndex!] = entry
		}
		
		return savePhonebookData(entries: allEntries)
	}
	
	/// Deletes an entry from the phonebook
	/// - Parameters:
	///   - entry: The phone entry to delete
	///   - allEntries: The current array of all entries
	/// - Returns: Updated array of all entries
	static func deleteEntry(_ entry: PhoneEntry, from allEntries: inout [PhoneEntry]) -> Bool {
		allEntries.removeAll { $0.id == entry.id }
		return savePhonebookData(entries: allEntries)
	}
}
