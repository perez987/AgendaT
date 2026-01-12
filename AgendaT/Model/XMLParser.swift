import Foundation

class PhonebookXMLParser: NSObject, XMLParserDelegate {
    private var entries: [PhoneEntry] = []
    private var currentElement = ""
    private var currentName = ""
    private var currentPhone1 = ""
    private var currentPhone2 = ""
    private var currentID = ""
    
    func parse(data: Data) -> [PhoneEntry] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        print("Starting XML parsing...")
        let success = parser.parse()
        if success {
            print("XML parsing completed successfully. Parsed \(entries.count) contacts.")
        } else {
            print("XML parsing failed with error: \(parser.parserError?.localizedDescription ?? "Unknown error")")
        }
        return entries
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "Contact" {
            currentName = ""
            currentPhone1 = ""
            currentPhone2 = ""
            currentID = ""
        }
    }

		// Phone columns allow numbers only
	private func validatePhoneNumber(_ phone: String) -> String {
		return phone.filter { $0.isNumber }
	}

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        switch currentElement {
        case "Name":
            currentName += trimmed
        case "Phone1":
            currentPhone1 += trimmed
        case "Phone2":
            currentPhone2 += trimmed
        case "ID":
            currentID += trimmed
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Contact" {
            if let id = Int(currentID) {
                let entry = PhoneEntry(
                    id: id,
                    name: currentName,
                    phone1: validatePhoneNumber(currentPhone1),
                    phone2: validatePhoneNumber(currentPhone2)
                )
                entries.append(entry)
                print("Parsed contact: \(currentName) (ID: \(id))")
            } else {
                print("Skipped contact '\(currentName)' - missing or invalid ID")
            }
        }
    }
}

func loadPhonebookData() -> [PhoneEntry] {
    print("Loading phonebook data...")
    
    // Try to load from documents directory first (for edited data)
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let documentsPhonebookURL = documentsURL.appendingPathComponent("Phonebook.xml")
    
    var dataURL: URL
    
    if FileManager.default.fileExists(atPath: documentsPhonebookURL.path) {
        dataURL = documentsPhonebookURL
        print("Loading from documents directory: \(documentsPhonebookURL.path)")
    } else {
        // Load from bundle and copy to documents directory
        guard let bundleURL = Bundle.main.url(forResource: "Phonebook", withExtension: "xml") else {
            print("Error: Phonebook.xml not found in bundle")
            return []
        }
        
        print("Found Phonebook.xml in bundle at: \(bundleURL.path)")
        
        // Copy to documents directory for future edits
        do {
            try FileManager.default.copyItem(at: bundleURL, to: documentsPhonebookURL)
            print("Copied Phonebook.xml to documents directory")
            dataURL = documentsPhonebookURL
        } catch {
            print("Failed to copy Phonebook.xml to documents directory: \(error.localizedDescription)")
            dataURL = bundleURL
        }
    }
    
    guard let data = try? Data(contentsOf: dataURL) else {
        print("Error: Failed to read data from Phonebook.xml")
        return []
    }
    
    print("Successfully loaded \(data.count) bytes from Phonebook.xml")
    
    let parser = PhonebookXMLParser()
    let entries = parser.parse(data: data)
    
    // Sort contacts by name (case-insensitive, locale-aware)
    let sortedEntries = entries.sorted { entry1, entry2 in
        entry1.name.localizedCaseInsensitiveCompare(entry2.name) == .orderedAscending
    }
    
    print("Contacts sorted by name. Total: \(sortedEntries.count) contacts")
    
    if !sortedEntries.isEmpty {
        print("   First contact: \(sortedEntries.first?.name ?? "Unknown")")
        print("   Last contact: \(sortedEntries.last?.name ?? "Unknown")")
    }
    
    return sortedEntries
}

func savePhonebookData(entries: [PhoneEntry]) -> Bool {
    print("Saving phonebook data...")
    
    // Save to documents directory
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let documentsPhonebookURL = documentsURL.appendingPathComponent("Phonebook.xml")
    
    // Helper function to escape XML special characters
    func escapeXML(_ text: String) -> String {
        return text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "'", with: "&apos;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
    
    // Create XML string
    var xmlString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Phonebook>\n"
    
    for entry in entries {
        xmlString += "        <Contact>\n"
        xmlString += "            <Name>\(escapeXML(entry.name))</Name>\n"
        xmlString += "            <Phone1>\(entry.phone1)</Phone1>\n"
        xmlString += "            <Phone2>\(entry.phone2)</Phone2>\n"
        xmlString += "            <ID>\(entry.id)</ID>\n"
        xmlString += "        </Contact>\n"
    }
    
    xmlString += "</Phonebook>\n"
    
    do {
        try xmlString.write(to: documentsPhonebookURL, atomically: true, encoding: .utf8)
        print("Successfully saved \(entries.count) contacts to: \(documentsPhonebookURL.path)")
        return true
    } catch {
        print("Error saving Phonebook.xml: \(error.localizedDescription)")
        return false
    }
}
