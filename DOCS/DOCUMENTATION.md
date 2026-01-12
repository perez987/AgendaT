# AgendaT - Technical Documentation

## Architecture

### Core Technologies

- **SwiftUI**: Modern declarative UI framework
- **XML Parsing**: Native Foundation XMLParser for data handling
- **Multi-language Support**: Built-in localization system with automatic language detection

### Project Structure

```
AgendaT/
├── AgendaTApp.swift              # Main application entry point
├── AppDelegate.swift             # Application delegate
├── AgendaT.entitlements          # App entitlements and capabilities
├── Assets.xcassets/              # App icons and visual assets
│   ├── AccentColor.colorset/
│   └── AppIcon.appiconset/
├── Models/
│   ├── FilterSortManager.swift   # Filtering and sorting logic
│   ├── LocalizationManager.swift # Language detection and localization
│   ├── PhoneEntry.swift          # Data model for phone entries
│   ├── PhonebookManager.swift    # Phonebook data management
│   └── XMLParser.swift           # XML parsing functionality
├── Resources/
│   ├── Phonebook.xml             # Contact data storage
│   ├── en.lproj/                 # English localization
│   │   └── Localizable.strings
│   ├── es.lproj/                 # Spanish localization
│   │   └── Localizable.strings
│   └── fr.lproj/                 # French localization
│       └── Localizable.strings
└── Views/
    └── ContentView.swift         # Main UI with grid, search, and filters
```

## Key Components

### 1. Data Model (PhoneEntry.swift)

The `PhoneEntry` struct represents a single contact with:

- **id**: Unique numeric identifier (required, non-null)
- **name**: Contact name
- **phone1**: Primary phone number (numeric only)
- **phone2**: Secondary phone number (numeric only)

Implements:

- `Identifiable`: For SwiftUI list/grid rendering
- `Codable`: For potential JSON serialization support
- `Equatable`: For comparing entries

**Note:** All properties are mutable (`var`) to support editing functionality.

### 2. XML Parser (XMLParser.swift)

**PhonebookXMLParser Class:**

- Implements `XMLParserDelegate` for SAX-style parsing
- Parses `phonebook.xml` with `<Contact>` elements containing `<Name>`, `<Phone1>`, `<Phone2>`, and `<ID>` sub-elements
- Returns array of `PhoneEntry` objects
- Handles malformed data gracefully (skips invalid entries)

**loadPhonebookData() Function:**

- Loads `phonebook.xml` from documents directory (or copies from bundle on first run)
- Returns empty array if file not found (fail-safe)
- Sorts contacts alphabetically by name using locale-aware, case-insensitive comparison
- Provides detailed error handling and logging:
  - File loading status
  - XML parsing progress
  - Individual contact parsing with ID validation
  - Warnings for contacts with missing IDs
  - First and last contact names after sorting

**savePhonebookData() Function:**

- Saves edited contacts to documents directory (bundle resources are read-only)
- Escapes XML special characters (&, <, >, ', ") in contact names
- Creates properly formatted XML with indentation
- Returns success/failure status
- Provides detailed logging for debugging

### 3. User Interface (ContentView.swift)

**Main Features:**

- **Sortable Grid Display**: LazyVGrid with 4 clickable column headers (Name, Phone 1, Phone 2, ID)
- **Column Sorting**: Click any column header to sort by that field (ascending/descending toggle)
- **Sort Indicators**: Visual chevron icons show current sort field and direction
- **Text Search**: TextField for name-based partial matching
- **Alphabet Filter**: 26 letter buttons (A-Z) for first-letter filtering
- **Combined Filtering**: Text search and letter filter work together
- **Record Counter**: Displays current filtered count
- **Add Contact**: Button to create new contacts
- **Edit Contact**: Click on contact name to edit
- **Delete Contact**: Trash icon next to each contact's ID

**State Management:**

- `@State` properties for reactive UI updates
- `allEntries`: Complete dataset loaded on appear
- `filteredEntries`: Current view after applying filters and sorting
- `searchText`: User's search input
- `selectedLetter`: Currently selected letter filter
- `sortField`: Current sorting column (name, phone1, phone2, id)
- `sortAscending`: Sort direction flag
- `editingEntry`: Contact being edited

**Filtering and Sorting Logic:**

- Letter filter: Case-insensitive prefix matching
- Text search: Case-insensitive substring matching (`localizedCaseInsensitiveContains`)
- Filters combine (AND logic) when both are active
- Sorting applied after filtering
- Sort toggle: Click same column header to reverse direction
- Clear button resets filters but maintains sort preference

**Edit Dialog (EditContactView):**

- Modal sheet for adding/editing contacts
- Form with fields for Name, Phone1, Phone2
- Phone fields automatically filter non-numeric input
- ID field read-only (auto-generated for new contacts)
- Save button disabled when name is empty
- Keyboard shortcuts (Escape for cancel, Enter for save)

### 4. Localization System (LocalizationManager.swift)

**Automatic Language Detection:**

- Reads macOS system language preferences via `Locale.preferredLanguages`
- Supports three languages: English (en), Spanish (es), French (fr)
- Falls back to English if system language not supported
- No manual language selector required

**LocalizationManager Class:**

- Singleton pattern (`shared` instance)
- Detects language on initialization
- Provides `localizedString(_:)` method for key lookups
- Implements fallback chain: Current Language → English → Key itself

**Global Helper Function:**

- `localized(_:)` for convenient access throughout the app
- Usage: `Text(localized("phone_numbers"))`

## Language Support Details

### Supported Languages

1. **English (en)**: Default and fallback language
2. **Spanish (es)**: Full translation of UI elements
3. **French (fr)**: Full translation of UI elements

### Detection Process

1. App reads system language preferences on launch
2. Extracts language code (first 2 characters)
3. Checks if code matches supported languages
4. Selects first match or defaults to English
5. Loads corresponding `.lproj` bundle for string localization

### Adding New Languages

To add support for additional languages:

1. Create new `.lproj` directory (e.g., `de.lproj` for German)
2. Add `Localizable.strings` with translations
3. Update `supportedLanguages` array in `LocalizationManager`
4. No code changes required in views

## Data Format

### XML Structure

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Phonebook>
    <Contact>
        <Name>John Doe</Name>
        <Phone1>1234567890</Phone1>
        <Phone2>9876543210</Phone2>
        <ID>1</ID>
    </Contact>
    <!-- More contacts... -->
</Phonebook>
```

**Requirements:**

- Root element: `<Phonebook>`
- Each contact: `<Contact>` element
- Required fields: `<ID>` (integer), `<Name>`, `<Phone1>`, `<Phone2>`
- Phone numbers: Numeric strings (validation not enforced)
- IDs must be unique (application doesn't enforce, but expected)

XML file is saved in user's documents folder (not bundle):

`~/Library/Containers/perez987.AgendaT/Data/Documents/Phonebook.xml`

## Design Considerations

### Performance

- **LazyVGrid**: Efficient rendering for large datasets (only visible items rendered)
- **In-memory filtering**: All filtering done on loaded dataset (no re-parsing)
- **Single XML parse**: Data loaded once on app launch
- **Alphabetical sorting**: Contacts sorted using efficient locale-aware comparison
- **Efficient sorting**: Sorting applied to filtered results, not entire dataset

### User Experience

- **Multi-column sorting**: Click any column header to sort; click again to reverse
- **Visual sort indicators**: Chevron icons show active sort column and direction
- **Alphabetical order**: Contacts can be sorted by name, phone numbers, or ID
- **Visual indicators**: Selected letter highlighted with accent color
- **Clear action**: Single button resets all filters to initial state
- **Edit functionality**: Click contact name to edit, trash icon to delete
- **Modal editing**: Clean edit dialog with validation and keyboard shortcuts
- **Auto-generated IDs**: New contacts automatically get unique IDs
- **Debug logging**: Comprehensive console output for easy identification

## Future Enhancement Opportunities

### Potential Features

- Phone number validation and formatting
- Dark mode optimization
- Import/export functionality for different formats
- Contact grouping and categories
- Search history

### Localization Extensions

- Date/number formatting per locale
- Localized contact sorting (locale-aware collation)

## Development Requirements

### System Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.0 or later

### Building the Project

1. Open `AgendaT.xcodeproj` in Xcode
2. Select target device/architecture
3. Build and run (⌘R)

## SwiftUI Patterns

- Extract complex views into separate components when needed
- Use `@State` for local state, `@StateObject` for observable objects
- Prefer modifiers over conditional rendering
- Keep view bodies focused and readable

## Known Limitations

2. **Single file source**: All data must fit in one XML file
3. **No contact validation**: Duplicate IDs or invalid data not prevented at app level
4. **No iCloud sync**: Local data only
5. **Manual ID management**: User cannot edit contact IDs (auto-assigned)

## Accessibility Considerations

- All interactive elements keyboard-accessible
- VoiceOver compatible (native SwiftUI support)
- Text scales with system font size settings
- Color contrast meets accessibility guidelines (gray opacity values tested)
- Semantic structure maintained (headers, lists, buttons)

## Security & Privacy

- **No network access**: Fully offline application
- **Local data only**: XML file stored in documents directory
- **No user tracking**: No analytics or telemetry
- **Sandboxed**: Standard macOS app sandbox restrictions
- **Editable storage**: Data persists in user-accessible documents folder
- **XML escaping**: Special characters properly escaped to prevent injection

