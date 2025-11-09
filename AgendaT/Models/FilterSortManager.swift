import Foundation

/// Manages filtering and sorting operations for phonebook entries
class FilterSortManager {
	/// Applies filters (letter and search text) to the entries
	/// - Parameters:
	///   - allEntries: The complete array of all entries
	///   - selectedLetter: Optional letter filter (entries starting with this letter)
	///   - searchText: Optional search text (entries containing this text in name)
	///   - sortField: The field to sort by
	///   - sortAscending: Whether to sort in ascending order
	/// - Returns: Filtered and sorted array of entries
	static func applyFilters(
		to allEntries: [PhoneEntry],
		selectedLetter: String?,
		searchText: String,
		sortField: SortField,
		sortAscending: Bool
	) -> [PhoneEntry] {
		var results = allEntries
		
		// Apply letter filter
		if let letter = selectedLetter {
			results = results.filter { entry in
				entry.name.uppercased().hasPrefix(letter)
			}
		}
		
		// Apply name search filter
		if !searchText.isEmpty {
			results = results.filter { entry in
				entry.name.localizedCaseInsensitiveContains(searchText)
			}
		}
		
		return sortEntries(results, by: sortField, ascending: sortAscending)
	}
	
	/// Sorts entries by the specified field and direction
	/// - Parameters:
	///   - entries: The array of entries to sort
	///   - sortField: The field to sort by
	///   - sortAscending: Whether to sort in ascending order
	/// - Returns: Sorted array of entries
	static func sortEntries(_ entries: [PhoneEntry], by sortField: SortField, ascending sortAscending: Bool) -> [PhoneEntry] {
		return entries.sorted { entry1, entry2 in
			let comparison: ComparisonResult
			switch sortField {
			case .name:
				comparison = entry1.name.localizedCaseInsensitiveCompare(entry2.name)
			case .phone1:
				comparison = entry1.phone1.compare(entry2.phone1)
			case .phone2:
				comparison = entry1.phone2.compare(entry2.phone2)
			case .id:
				comparison = entry1.id < entry2.id ? .orderedAscending : (entry1.id > entry2.id ? .orderedDescending : .orderedSame)
			}
			return sortAscending ? comparison == .orderedAscending : comparison == .orderedDescending
		}
	}
}
