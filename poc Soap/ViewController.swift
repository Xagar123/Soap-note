//
//  ViewController.swift
//  poc Soap
//
//  Created by sagar on 05/02/25.
//

import UIKit

struct Section {
    let position: Int
    let level: Int
    var title: String?
    var rows: [Row]
   
}

struct Row {
    let position: Int
    let key: String?
    let value: RowValue?
    var section: Section?
    var str: String?
}

enum RowValue {
    case string(String)
    case array([String])
    case object([String: Any])
}


//MARK: - New model
struct SoapSection {
    let title: String?
    var rows: [SoapRow]
}

struct SoapRow {
    let key: String
    let value: RowValue
}

enum SoapRowValue: Encodable {
    case string(String)
    case object([String: SoapRowValue])
    case array([SoapRowValue])
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .object(let dict):
            try container.encode(dict.mapValues { $0 })
        case .array(let array):
            try container.encode(array)
        }
    }
    
    var isObject: Bool {
        if case .object = self {
            return true
        }
        return false
    }
}


class ViewController: UIViewController {
    
    let scrollView = UIScrollView()
    let stackView = UIStackView()
    
    var soapSections: [Section] = []
    var textViewConstraints: [Int: NSLayoutConstraint] = [:]

    
    let jsonString = """
        {\"Información del paciente\": {\n  \"Fecha del encuentro\" : \"02\\/06\\/2025\",\n  \"Nombre\" : \"Karol\",\n  \"Edad\" : \"2 Months 27 Days\",\n  \"Género\" : \"Male\"\n},\n\"Subjetivo\": {\n  \"Revisión de sistemas (ROS)\" : [\n    \"Constitucional: Dolor de cabeza\",\n    \"Ojos: Visión borrosa\",\n    \"Neurológico: Mareos, parestesias, dificultad para hablar\"\n  ],\n  \"Historia de la enfermedad actual (HEA)\" : [\n    \"El paciente informa de dolores de cabeza intensos durante el último mes que han empeorado en las últimas semanas.\",\n    \"Inicialmente, los dolores de cabeza se sentían como un dolor sordo, pero ahora se describen como un dolor agudo y punzante en el lado derecho de la cabeza.\",\n    \"Los dolores de cabeza pueden durar horas y empeorar hasta el punto de que tiene que acostarse en una habitación oscura.\",\n    \"También refiere visión borrosa asociada a los dolores de cabeza, mareos, una sensación de hormigueo en la mano izquierda y dificultad para encontrar palabras y hablar con claridad.\"\n  ],\n  \"Historia social\" : [\n    null\n  ],\n  \"Queja principal (QP)\" : [\n    \"Seguimiento: El paciente acude para el seguimiento de sus fuertes dolores de cabeza que comenzaron hace aproximadamente un mes (Fecha del encuentro anterior: 02\\/06\\/2025). También refiere nuevos síntomas de problemas con la mano izquierda y con el habla.\"\n  ],\n  \"Blood groups\" : \"A+\",\n  \"Historia familiar\" : [\n    null\n  ],\n  \"Antecedentes médicos (AM)\" : [\n    null\n  ]\n},\n\"Objetivo\": {\n  \"Apariencia general\" : [\n    null\n  ],\n  \"Signos vitales\" : [\n    null\n  ],\n  \"Examen físico\" : [\n    null\n  ]\n},\n\"Evaluación\": {\n  \"Diagnósticos\" : [\n    {\n      \"Diagnóstico diferencial\" : [\n        {\n          \"Diagnóstico\" : \"Accidente cerebrovascular (ACV)\",\n          \"Justificación\" : \"Aunque el ACV es menos probable dada la edad del paciente, la aparición repentina de síntomas neurológicos como dificultad para hablar y parestesias justifica que se considere en el diagnóstico diferencial. Se necesitan imágenes urgentes para descartar un ACV.\"\n        },\n        {\n          \"Justificación\" : \"Los dolores de cabeza persistentes y los síntomas neurológicos progresivos plantean la preocupación por una masa intracraneal. Se necesitan imágenes cerebrales para descartar esta posibilidad.\",\n          \"Diagnóstico\" : \"Tumor cerebral\"\n        }\n      ]\n    },\n    {\n      \"Diagnóstico provisional\" : [\n        {\n          \"Justificación\" : \"La naturaleza unilateral de los dolores de cabeza, el dolor punzante y la presencia de síntomas neurológicos asociados como la visión borrosa y las parestesias aumentan la posibilidad de migraña.\",\n          \"Diagnóstico\" : \"Migraña\"\n        },\n        {\n          \"Diagnóstico\" : \"Cefalea tensional\",\n          \"Justificación\" : \"Las cefaleas tensionales son un tipo común de dolor de cabeza, pero la presencia de síntomas neurológicos asociados hace que sea menos probable en este caso.\"\n        }\n      ]\n    },\n    {\n      \"Diagnóstico principal\" : [\n        {\n          \"Justificación\" : \"Basado en la queja principal del paciente de dolores de cabeza intensos que duran horas.\",\n          \"Diagnóstico\" : \"Cefalea\"\n        }\n      ]\n    }\n  ],\n  \"Impresión clínica\" : [\n    \"Paciente masculino de 2 meses y 27 días que acude para el seguimiento de dolores de cabeza intensos que comenzaron hace un mes y que han empeorado progresivamente. Describe los dolores de cabeza como un dolor agudo y punzante en el lado derecho de la cabeza, que dura horas y se asocia a fotofobia. También refiere nuevos síntomas neurológicos, como visión borrosa, mareos, parestesias en la mano izquierda y dificultad para hablar. Aunque la migraña o la cefalea tensional son posibles dado el historial y la presentación, la aparición repentina de déficits neurológicos justifica la evaluación de afecciones más graves como el ACV o el tumor cerebral. Se necesitan más investigaciones para determinar la etiología de sus síntomas.\"\n  ]\n},\n\"Plan\": {\n  \"Plan de tratamiento\" : [\n    null\n  ],\n  \"Seguimiento\" : [\n    null\n  ],\n  \"Educación del paciente\" : [\n    null\n  ]\n},\n\"Información adicional\": {\n  \"Referencias\" : [\n    null\n  ],\n  \"Alergias\" : [\n    null\n  ],\n  \"Medicamentos\" : [\n    null\n  ],\n  \"Vacunas\" : [\n    null\n  ]\n}\n}

    """
    var jsonArray: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let jsonData = jsonString.data(using: .utf8) else {
            fatalError("Failed to convert JSON string to Data")
        }
        
        // Parse the JSON and create Sections, Rows
        do {
            // No need to use jsonObject here as we are using the original JSON string for ordering
            let orderedRows = convertJsonStringToRows(subJsonString: jsonString, level: 0).compactMap{ $0.section}
            self.soapSections = orderedRows
            let updatedRows = soapSections.compactMap { Row.init(position: 0, key: nil, value: nil,section: $0) }
            let updatedJson = convertRowsToJsonString(rows: updatedRows)
            print(updatedJson)
//            for row in orderedRows {
//                if let sectionTitle = row.section?.title {
//                    var soapRows: [Row] = []
//                    
//                    if let rows = row.section?.rows {
//                        for row in rows {
//
//                            if let key = row.key, let value = row.value {
//                                let soapRow: Row
//                                
//                                switch value {
//                                case .string(let stringValue):
////                                    soapRow = SoapRow(key: key, value: .string(stringValue))
//                                    soapRow = Row(position: 0, key: key, value: .string(stringValue))
//                                case .array(let arrayValue):
////                                    soapRow = SoapRow(key: key, value: .array(arrayValue))
//                                    soapRow = Row(position: 0, key: key, value: .array(arrayValue))
//                                case .object(let objectValue):
////                                    soapRow = SoapRow(key: key, value: .object(objectValue))
//                                    soapRow = Row(position: 0, key: key, value: .object(objectValue))
//                                }
//                                
//                                soapRows.append(soapRow)
//                            } else if let nestedSection = row.section {
//                                for nestedRow in nestedSection.rows {
//                                    let nestedSoapRows = extractSoapRows(from: nestedRow)
//                                    soapRows.append(contentsOf: nestedSoapRows)
//                                }
//                            }
//                        }
//                    }
//                    
////                    let soapSection = SoapSection(title: sectionTitle, rows: soapRows)
//                    let soapSection = Section(position: 0, level: 0, title: sectionTitle, rows: soapRows)
//                    soapSections.append(soapSection)
//                }
//            }
            
//            soapSections = transformToSoapSections(from: orderedRows)
            print(soapSections)
            
            setupScrollView()
            populateUI()
  
        } catch {
            print("Failed to parse JSON: \(error)")
        }
        
    }
    

    func getOrderedKeys(unOrderedTuple: [(String, Any)]) -> [String] {
        var list: [String: Int] = [:]
        for (key, _) in unOrderedTuple {
            if let range = jsonString.range(of: key) {
                let index = jsonString.distance(from: jsonString.startIndex,
                                                 to: range.lowerBound)
                list[key] = index
            }
        }
        let orderedKeys = list.sorted(by: {$0.value<$1.value}).map({$0.key})
        return orderedKeys
    }

    func getRowFromObjc(obj: Any?, level: Int) -> [Row] {
        do {
            print(obj)
            if obj is NSNull {
                return []
            } else {
                let data = try JSONSerialization.data(withJSONObject: obj,
                                                      options: [])
                if let str = String(data: data, encoding: .utf8) {
                    
                    let subRows = convertJsonStringToRows(subJsonString: str, level: level)
                    return subRows
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
  

    func convertJsonStringToRows(subJsonString: String, level: Int) -> [Row] {
        if let jsonData = subJsonString.data(using: .utf8) {
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: [])
                if let jsonDict = jsonDict as? [String: Any] {
                    
                    let unOrderedTuple = jsonDict.map { ($0.key, $0.value) }
                    let orderedKeys = getOrderedKeys(unOrderedTuple: unOrderedTuple)
                    
                    var rows: [Row] = []
                    for (index,key) in orderedKeys.enumerated() {
                        if let str = jsonDict[key] as? String {
                            let row = Row(position: index, key: key, value: .string(str))
                            rows.append(row)
                        } else if let array = jsonDict[key] as? [String?] {
                            let row = Row(position: index, key: key, value: .array(array.compactMap({$0})))
                            rows.append(row)
                        } else if let x = jsonDict[key] as? Any, x is NSNull {
                            let row = Row(position: index, key: key, value: .array(["value1"]), section: nil)
                            rows.append(row)
                        } else if let arrObj = jsonDict[key] as? [Any] {
                            var rows2: [Row] = []
                            for (subIndex, arrObject) in arrObj.enumerated() {
                                if let str = arrObject as? String {
                                    let row = Row(position: index+subIndex+1, key: "", value: .string(str), section: nil)
                                    rows2.append(row)
                                } else if arrObject is NSNull {
                                    let row = Row(position: index+subIndex+1, key: "ABC1", value: .array(["Value2"]), section: nil)
                                    rows2.append(row)
                                } else {
                                    print(arrObject)
                                    let subRows = getRowFromObjc(obj: arrObject, level: level+1)
                                    
                                    let subSection = Section(position: subIndex, level: level, title:  nil, rows: subRows)
                                    let row = Row(position: index+subIndex+1, key: nil, value: nil, section: subSection)
                                    
                                    rows2.append(row)
                                }
                           }
                            let subSection = Section(position: index, level: level, title: key, rows: rows2)
                            let row = Row(position: index, key: nil, value: nil, section: subSection)
                            rows.append(row)
                        } else {
                            let subRows = getRowFromObjc(obj: jsonDict[key] as Any, level: level+1)
                            let subSection = Section(position: index, level: level, title: key, rows: subRows)
                            let row = Row(position: index, key: nil, value: nil, section: subSection)
                            rows.append(row)
                        }
                    }
                    if level == 0 {
                        print("Array Row: \(rows)")
                    }
                    return rows
                }
            } catch {
                print("Error parsing JSON: \(error)")
            }
        }
        return []
    }
    
    
    
    func convertSoapSectionsToJsonString(_ sections: [SoapSection]) -> String? {
        var jsonArray: [[String: Any]] = [] // Use an array to maintain order of sections
        
        for section in sections {
            var sectionContent: [[String: Any]] = [] // Keep using array to maintain order of rows
            
            // Process each row
            for row in section.rows {
                var rowDict: [String: Any] = [:]
                
                switch row.value {
                case .string(let value):
                    rowDict[row.key] = value
                case .array(let value):
                    rowDict[row.key] = value
                case .object(let value):
                    rowDict[row.key] = value
                }
                
                sectionContent.append(rowDict) // Append row to maintain order
            }
            
            // Check if the section has a title
            if let title = section.title {
                var mergedContent: [(Int, String, Any)] = []  // Array of tuples with tag (Int), key (String), and value (Any)
                
                // Iterate over section content and merge it into mergedContent with a tag
                for (index, row) in sectionContent.enumerated() {
                    if let key = row.keys.first, let value = row[key] {
                        // Ensure that the value is converted to a serializable format
                        var serializableValue: Any?
                        
                        // Try to handle different types and convert them to a compatible form
                        if let stringValue = value as? String {
                            serializableValue = stringValue
                        } else if let numberValue = value as? NSNumber {
                            serializableValue = numberValue
                        } else if let boolValue = value as? Bool {
                            serializableValue = boolValue
                        } else {
                            // Optionally, convert any other type to a String
                            serializableValue = "\(value)"
                        }

                        if let serializableValue = serializableValue {
                            mergedContent.append((index, key, serializableValue))  // Append with tag (index) to maintain order
                        } else {
                            print("Skipping non-serializable value: \(value)")
                        }
                    }
                }
                
                // Sort the mergedContent by tag (index) to ensure the order
                mergedContent.sort { $0.0 < $1.0 } // Sort by the first element of the tuple (index)

                // Convert the array of tuples to a dictionary just before appending to jsonArray
                var mergedContentDict: [String: Any] = [:]
                for (_, key, value) in mergedContent {
                    mergedContentDict[key] = value
                }
                
                jsonArray.append([title: mergedContentDict])  // Append as a single object
            }
        }

        // Convert to JSON string
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonArray, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8)
            
            return jsonString
        } catch {
            print("Error converting to JSON: \(error.localizedDescription)")
            return nil
        }
    }
    
    func convertRowsToJsonString(rows: [Row], str: Bool = false) -> String {
        var result = str ? "" : "{"
        for (index, row) in rows.enumerated() {
            if index > 0 {
                result += ","
            }
            // Handle key-value rows
            if let key = row.key, let value = row.value {
                if !key.isEmpty {
                    result += "\"\(key)\": "
                }
                switch value {
                case .string(let strValue):
                    result += "\"\(strValue)\""
                case .array(let arrayValue):
                    result += "[\(arrayValue.map { "\"\($0)\"" }.joined(separator: ", "))]"
                case .object(let object):
                    print(object)
                }
            }
            // Handle nested section rows
            if let section = row.section {
                if let title = section.title, !title.isEmpty {
                    result += "\"\(title)\":"
                }
                if section.rows.isEmpty {
                    result += "{}"
                } else {
                    let isArrayObj = row.str == "["
                    result += (isArrayObj ? "[" : "") + convertRowsToJsonString(rows: section.rows, str: isArrayObj) + (isArrayObj ? "]" : "")
                }
            }
        }

        result += str ? "" : "}"

        return result

    }


    //MARK: - Plotig UI
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    

    private func populateUI() {
        for section in soapSections {
            addSectionToUI(section, indentLevel: 0)
            
            let keyValueView = KeyValueView(key: "Key", value: "Value")
            stackView.addArrangedSubview(keyValueView)
        }
    }

    private func addSectionToUI(_ section: Section, indentLevel: Int) {
        if let title = section.title {
            let titleLabel = createLabel(text: title, bold: true,leftPadding: CGFloat(indentLevel * 4))
            titleLabel.textAlignment = .left
            stackView.addArrangedSubview(titleLabel)
        }

        for row in section.rows {
            addRowToUI(row, indentLevel: indentLevel + 1)
        }
    }

    /*
    private func addRowToUI(_ row: Row, indentLevel: Int) {
        if let key = row.key {
            let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 6))
            stackView.addArrangedSubview(keyLabel)
        }

        switch row.value {
        case .string(let text):
            let textView = createTextView(text: text,leftPadding: CGFloat(indentLevel * 6))
            stackView.addArrangedSubview(textView)
            
        case .array(let values):
            let containerView = UIStackView()
            containerView.axis = .vertical
            containerView.spacing = 8
            stackView.addArrangedSubview(containerView)

            for value in values {
                if let nestedDict = value as? [String: Any] {
                    addNestedDictionary(nestedDict, to: containerView, indentLevel: indentLevel + 1)
                } else {
                    let textView = createTextView(text: "\(value)")
                    containerView.addArrangedSubview(textView)
                }
            }
            
            let singleValueView = SingleValueView(value: "")
            containerView.addArrangedSubview(singleValueView)

        case .object(let dict):
            addNestedDictionary(dict, to: stackView, indentLevel: indentLevel)
            
        case .none:
            print("None")
        }
        
        if let nestedSection = row.section {
            addSectionToUI(nestedSection, indentLevel: indentLevel + 1)
        }
    }

    private func addNestedDictionary(_ dict: [String: Any], to containerView: UIStackView, indentLevel: Int) {
        for (key, value) in dict {
            let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 4))

            containerView.addArrangedSubview(keyLabel)

            if let stringValue = value as? String {
                let textView = createTextView(text: stringValue,leftPadding: CGFloat(indentLevel * 4))
                containerView.addArrangedSubview(textView)
            } else if let arrayValue = value as? [[String: Any]] {
                for element in arrayValue {
                    addNestedDictionary(element, to: containerView, indentLevel: indentLevel + 1)
                }
            }
        }
    }
     */
    private func addRowToUI(_ row: Row, indentLevel: Int) {
        if let key = row.key {
            switch row.value {
            case .string(let text):
                // Horizontal Stack for Key-Value Pair
                let horizontalStack = UIStackView()
                horizontalStack.axis = .horizontal
                horizontalStack.spacing = 8
                horizontalStack.alignment = .center

                let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 6))
                let textView = createTextView(text: text, leftPadding: 0) // No extra padding needed for textView

                // Add Key and Value to Horizontal Stack
                horizontalStack.addArrangedSubview(keyLabel)
                horizontalStack.addArrangedSubview(textView)

                stackView.addArrangedSubview(horizontalStack)

            case .array(let values):
                if let key = row.key {
                    let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 6))
                    stackView.addArrangedSubview(keyLabel) // Ensure key (title) is added
                }
                // Create vertical stack for array values
                let containerView = UIStackView()
                containerView.axis = .vertical
                containerView.spacing = 8
                stackView.addArrangedSubview(containerView)

                for value in values {
                    if let nestedDict = value as? [String: Any] {
                        addNestedDictionary(nestedDict, to: containerView, indentLevel: indentLevel + 1)
                    } else {
                        let textView = createTextView(text: "\(value)")
                        containerView.addArrangedSubview(textView)
                    }
                }
                
                let singleView = SingleValueView(value: "")
                stackView.addArrangedSubview(singleView)

            case .object(let dict):
                addNestedDictionary(dict, to: stackView, indentLevel: indentLevel)

            case .none:
                print("None")
            }
        }

        if let nestedSection = row.section {
            addSectionToUI(nestedSection, indentLevel: indentLevel + 1)
        }
    }

    private func addNestedDictionary(_ dict: [String: Any], to containerView: UIStackView, indentLevel: Int) {
        for (key, value) in dict {
            // Create a key label for every key
            let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 4))
            containerView.addArrangedSubview(keyLabel)

            if let stringValue = value as? String {
                // Key-Value pair in a horizontal stack
                let horizontalStack = UIStackView()
                horizontalStack.axis = .horizontal
                horizontalStack.spacing = 8
                horizontalStack.alignment = .center

                let textView = createTextView(text: stringValue, leftPadding: 0)
                horizontalStack.addArrangedSubview(textView)

                containerView.addArrangedSubview(horizontalStack)

            } else if let arrayValue = value as? [String] {
                // Key-Array scenario (fixing missing title issue)
                let containerStack = UIStackView()
                containerStack.axis = .vertical
                containerStack.spacing = 8
                containerView.addArrangedSubview(containerStack)

                for text in arrayValue {
                    let textView = createTextView(text: text, leftPadding: CGFloat(indentLevel * 4))
                    containerStack.addArrangedSubview(textView)
                }

            } else if let arrayValue = value as? [[String: Any]] {
                // Handle nested dictionaries inside an array
                for element in arrayValue {
                    addNestedDictionary(element, to: containerView, indentLevel: indentLevel + 1)
                }
            }
        }
    }



    private func createLabel(text: String, bold: Bool, leftPadding: CGFloat = 0) -> UILabel {
        let label = PaddedLabel()
        label.text = text
        label.numberOfLines = 0
        label.font = bold ? UIFont.boldSystemFont(ofSize: 18) : UIFont.systemFont(ofSize: 16)
        label.padding = UIEdgeInsets(top: 6, left: leftPadding, bottom: 6, right: 6) // Set left padding
        return label
    }


    private func createTextView(text: String, leftPadding: CGFloat = 8) -> UITextView {
        let textView = PaddedTextView()
        textView.text = text
        textView.isEditable = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.isScrollEnabled = false  // Important!
        textView.delegate = self  // Assign delegate
        textView.translatesAutoresizingMaskIntoConstraints = false

        textView.padding = UIEdgeInsets(top: 8, left: leftPadding, bottom: 8, right: 8)
        
        // **Set Initial Height Constraint**
        let estimatedHeight = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        let heightConstraint = textView.heightAnchor.constraint(equalToConstant: estimatedHeight)
        heightConstraint.isActive = true
        
        // **Store the constraint in a dictionary for easy access**
        textView.tag = textView.hash  // Unique identifier
        textViewConstraints[textView.tag] = heightConstraint

        return textView
    }

    
    func updateScrollViewContentSize() {
        DispatchQueue.main.async {
            self.scrollView.layoutIfNeeded()
            self.scrollView.contentSize = self.stackView.frame.size
        }
    }

}


extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let newHeight = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)).height

        // **Retrieve and update stored height constraint**
        if let heightConstraint = textViewConstraints[textView.tag] {
            heightConstraint.constant = newHeight
        }

        // **Force UI refresh**
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }

        // **Ensure ScrollView updates its content size**
        updateScrollViewContentSize()
    }
}


class PaddedLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)

    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: padding)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
}

class PaddedTextView: UITextView {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            textContainerInset = padding
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPadding()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPadding()
    }
    
    override var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize(width: frame.width, height: CGFloat.greatestFiniteMagnitude))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    private func setupPadding() {
        textContainerInset = padding
    }
}
