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
    var value: RowValue?
    var section: Section?
    var str: String?
    var tag: Int = 0
    var elementTags: [Int]?
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
    
    let customTopView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .cyan
        return view
    }()
    
    let finalizedBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Final", for: .normal)
        btn.backgroundColor = .lightGray
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    let editOrSaveBtn: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(systemName: "pencil"), for: .normal)
        btn.setTitle(" Edit", for: .normal)
        btn.setTitleColor(.systemBlue, for: .normal)
        
        btn.semanticContentAttribute = .forceLeftToRight
        btn.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        btn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        btn.tintColor = .white
        
        return btn
    }()

    
    var soapSections: [Section] = []
    var textViewConstraints: [Int: NSLayoutConstraint] = [:]
    private var tagCounter = 1000
    
    var encounterStatus = ""
    var isEditingMode = true
    
    let jsonString = """
    {\"Información del paciente\": {\n  \"Fecha del encuentro\" : \"02\\/06\\/2025\",\n  \"Nombre\" : \"Karol\",\n  \"Edad\" : \"2 Months 27 Days\",\n  \"Género\" : \"Male\"\n},\n\"Subjetivo\": {\n  \"Revisión de sistemas (ROS)\" : [\n    \"Constitucional: Dolor de cabeza\",\n    \"Ojos: Visión borrosa\",\n    \"Neurológico: Mareos, parestesias, dificultad para hablar\"\n  ],\n  \"Historia de la enfermedad actual (HEA)\" : [\n    \"El paciente informa de dolores de cabeza intensos durante el último mes que han empeorado en las últimas semanas.\",\n    \"Inicialmente, los dolores de cabeza se sentían como un dolor sordo, pero ahora se describen como un dolor agudo y punzante en el lado derecho de la cabeza.\",\n    \"Los dolores de cabeza pueden durar horas y empeorar hasta el punto de que tiene que acostarse en una habitación oscura.\",\n    \"También refiere visión borrosa asociada a los dolores de cabeza, mareos, una sensación de hormigueo en la mano izquierda y dificultad para encontrar palabras y hablar con claridad.\"\n  ],\n  \"Historia social\" : [\n    null\n  ],\n  \"Queja principal (QP)\" : [\n    \"Seguimiento: El paciente acude para el seguimiento de sus fuertes dolores de cabeza que comenzaron hace aproximadamente un mes (Fecha del encuentro anterior: 02\\/06\\/2025). También refiere nuevos síntomas de problemas con la mano izquierda y con el habla.\"\n  ],\n  \"Blood groups**editable**\" : \"A+\",\n  \"Historia familiar\" : [\n    null\n  ],\n  \"Antecedentes médicos (AM)\" : [\n    null\n  ]\n},\n\"Objetivo\": {\n  \"Apariencia general\" : [\n    null\n  ],\n  \"Signos vitales\" : [\n    null\n  ],\n  \"Examen físico\" : [\n    null\n  ]\n},\n\"Evaluación\": {\n  \"Diagnósticos\" : [\n    {\n      \"Diagnóstico diferencial\" : [\n        {\n          \"Diagnóstico\" : \"Accidente cerebrovascular (ACV)\",\n          \"Justificación\" : \"Aunque el ACV es menos probable dada la edad del paciente, la aparición repentina de síntomas neurológicos como dificultad para hablar y parestesias justifica que se considere en el diagnóstico diferencial. Se necesitan imágenes urgentes para descartar un ACV.\"\n        },\n        {\n          \"Justificación\" : \"Los dolores de cabeza persistentes y los síntomas neurológicos progresivos plantean la preocupación por una masa intracraneal. Se necesitan imágenes cerebrales para descartar esta posibilidad.\",\n          \"Diagnóstico\" : \"Tumor cerebral\"\n        }\n      ]\n    },\n    {\n      \"Diagnóstico provisional\" : [\n        {\n          \"Justificación\" : \"La naturaleza unilateral de los dolores de cabeza, el dolor punzante y la presencia de síntomas neurológicos asociados como la visión borrosa y las parestesias aumentan la posibilidad de migraña.\",\n          \"Diagnóstico\" : \"Migraña\"\n        },\n        {\n          \"Diagnóstico\" : \"Cefalea tensional\",\n          \"Justificación\" : \"Las cefaleas tensionales son un tipo común de dolor de cabeza, pero la presencia de síntomas neurológicos asociados hace que sea menos probable en este caso.\"\n        }\n      ]\n    },\n    {\n      \"Diagnóstico principal\" : [\n        {\n          \"Justificación\" : \"Basado en la queja principal del paciente de dolores de cabeza intensos que duran horas.\",\n          \"Diagnóstico\" : \"Cefalea\"\n        }\n      ]\n    }\n  ],\n  \"Impresión clínica\" : [\n    \"Paciente masculino de 2 meses y 27 días que acude para el seguimiento de dolores de cabeza intensos que comenzaron hace un mes y que han empeorado progresivamente. Describe los dolores de cabeza como un dolor agudo y punzante en el lado derecho de la cabeza, que dura horas y se asocia a fotofobia. También refiere nuevos síntomas neurológicos, como visión borrosa, mareos, parestesias en la mano izquierda y dificultad para hablar. Aunque la migraña o la cefalea tensional son posibles dado el historial y la presentación, la aparición repentina de déficits neurológicos justifica la evaluación de afecciones más graves como el ACV o el tumor cerebral. Se necesitan más investigaciones para determinar la etiología de sus síntomas.\"\n  ]\n},\n\"Plan\": {\n  \"Plan de tratamiento\" : [\n    null\n  ],\n  \"Seguimiento\" : [\n    null\n  ],\n  \"Educación del paciente\" : [\n    null\n  ]\n},\n\"Información adicional\": {\n  \"Referencias\" : [\n    null\n  ],\n  \"Alergias\" : [\n    null\n  ],\n  \"Medicamentos\" : [\n    null\n  ],\n  \"Vacunas\" : [\n    null\n  ]\n}\n}
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
           
            print(soapSections)
            
            setupScrollView()
            self.encounterStatus = "isFinal"
            populateUI(encounterStatus: encounterStatus)
            
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
                            let tag = getUniqueTag()
                            let row = Row(position: index, key: key, value: .string(str),tag: tag)
                            rows.append(row)
                        } else if let array = jsonDict[key] as? [String?] {
                          
                            let tag = getUniqueTag()
//                            let taggedValues = array.map { $0 ?? "" }.enumerated().map { index, value in
                            let taggedValues = array.compactMap{ $0 }.enumerated().map { index, value in
                                return (value, tag * 10 + index)
                            }
                            let row = Row(position: index, key: key, value: .array(taggedValues.map { $0.0 }), tag: tag, elementTags: taggedValues.map { $0.1 })
                            rows.append(row)
                        } else if let x = jsonDict[key] as? Any, x is NSNull {
                            let tag = getUniqueTag()
                            let row = Row(position: index, key: key, value: .array(["value1"]), section: nil, tag: tag)
                            rows.append(row)
                        } else if let arrObj = jsonDict[key] as? [Any] {
                            var rows2: [Row] = []
                            for (subIndex, arrObject) in arrObj.enumerated() {
                                if let str = arrObject as? String {
                                    let tag = getUniqueTag()
                                    let row = Row(position: index+subIndex+1, key: "", value: .string(str), section: nil,tag: tag)
                                    rows2.append(row)
                                } else if arrObject is NSNull {
                                    let tag = getUniqueTag()
                                    let row = Row(position: index+subIndex+1, key: "ABC1", value: .array(["Value2"]), section: nil,tag: tag)
                                    rows2.append(row)
                                } else {
                                    print(arrObject)
                                    let subRows = getRowFromObjc(obj: arrObject, level: level+1)
                                    
                                    let subSection = Section(position: subIndex, level: level, title:  nil, rows: subRows)
                                    let tag = getUniqueTag()
                                    let row = Row(position: index+subIndex+1, key: nil, value: nil, section: subSection,tag: tag)
                                    
                                    rows2.append(row)
                                }
                            }
                            let subSection = Section(position: index, level: level, title: key, rows: rows2)
                            let tag = getUniqueTag()
                            let row = Row(position: index, key: nil, value: nil, section: subSection,tag: tag)
                            rows.append(row)
                        } else {
                            let subRows = getRowFromObjc(obj: jsonDict[key] as Any, level: level+1)
                            let subSection = Section(position: index, level: level, title: key, rows: subRows)
                            let tag = getUniqueTag()
                            let row = Row(position: index, key: nil, value: nil, section: subSection,tag: tag)
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
        view.backgroundColor = UIColor(red: 0.075, green: 0.073, blue: 0.163, alpha: 1)
        view.addSubview(customTopView)
        view.addSubview(scrollView)
        
        
        customTopView.addSubview(finalizedBtn)
        customTopView.addSubview(editOrSaveBtn)
        
        NSLayoutConstraint.activate([
            editOrSaveBtn.topAnchor.constraint(equalTo: customTopView.topAnchor,constant: 10),
            editOrSaveBtn.trailingAnchor.constraint(equalTo: customTopView.trailingAnchor,constant: -20),
            editOrSaveBtn.bottomAnchor.constraint(equalTo: customTopView.bottomAnchor,constant: -10),
            editOrSaveBtn.widthAnchor.constraint(equalToConstant: 80),
            
            finalizedBtn.topAnchor.constraint(equalTo: customTopView.topAnchor,constant: 10),
            finalizedBtn.leadingAnchor.constraint(equalTo: customTopView.leadingAnchor, constant: 20),
            finalizedBtn.bottomAnchor.constraint(equalTo: customTopView.bottomAnchor,constant: -10),
            finalizedBtn.widthAnchor.constraint(equalToConstant: 100),
        ])
        
        NSLayoutConstraint.activate([
            customTopView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customTopView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTopView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTopView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: customTopView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        stackView.axis = .vertical
        stackView.spacing = 8
//        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
        
        finalizedBtn.addTarget(self, action: #selector(finalizedBtnTapped), for: .touchUpInside)
        editOrSaveBtn.addTarget(self, action: #selector(editOrSaveBtnTapped), for: .touchUpInside)
    }
    
    
    //MARK: - Ploating UI
    private func populateUI(encounterStatus: String) {
        for section in soapSections {
            addSectionToUI(section, indentLevel: 0, encounterStatus: encounterStatus)
            
            let keyValueView = KeyValueView(key: "", value: "")
            keyValueView.keyTextView.tag = section.position
            keyValueView.valueTextView.tag = section.position
            keyValueView.addSectionLabel.text = "+  Add   \(String(describing: section.title ?? ""))"
            stackView.addArrangedSubview(keyValueView)
//            stackView.alignment = .fill
            
            keyValueView.configureView(encounterStatus: encounterStatus)
            
            keyValueView.addAction = { key,value,tag in
                self.appendNewElementInSection(tag: tag, key: key, value: value)
            }
            
        }
        
    }
    
    private func addSectionToUI(_ section: Section, indentLevel: Int, encounterStatus: String) {
        if let title = section.title {
            
            let horizontalStack = UIStackView()
            horizontalStack.axis = .horizontal
            horizontalStack.spacing = 8
            horizontalStack.distribution = .fill
            
            let titleLabel = createLabel(text: title, bold: true,leftPadding: CGFloat(indentLevel * 4), position: indentLevel)
            titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
            titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            titleLabel.textAlignment = .left
//            stackView.alignment = (indentLevel == 0) ? .leading : .fill
//            stackView.addArrangedSubview(titleLabel)
            
            let spacerView = UIView()
            
            horizontalStack.addArrangedSubview(titleLabel)
            horizontalStack.addArrangedSubview(spacerView)
            
            stackView.addArrangedSubview(horizontalStack)
           
        }
        
        for row in section.rows {
            addRowToUI(row, indentLevel: indentLevel + 1, encounterStatus: encounterStatus)
        }
    }
    
    
    private func addRowToUI(_ row: Row, indentLevel: Int, encounterStatus: String) {
        if let key = row.key {
            switch row.value {
            case .string(let text):
                let horizontalStack = UIStackView()
                horizontalStack.axis = (indentLevel == 1) ? .horizontal : .vertical
                horizontalStack.spacing = 8
                horizontalStack.distribution = .fill
                
                let colonLabel = UILabel()
                colonLabel.text = ":"
                colonLabel.textColor = .white
                colonLabel.widthAnchor.constraint(equalToConstant: 10).isActive = true

                let leftPadding = CGFloat(indentLevel * (indentLevel == 1 ? 0 : 6))
                let textView = createTextView(text: text, leftPadding: leftPadding, currentTag: row.tag)
                textView.tag = row.tag

                let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 6), position: indentLevel)
                
                keyLabel.setContentHuggingPriority(.required, for: .horizontal)
                keyLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
                
                textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
                textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
                
                let minLabelWidth: CGFloat = 50
                let keyLabelWidthCons = keyLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: minLabelWidth)
                keyLabelWidthCons.priority = .defaultLow
                keyLabelWidthCons.isActive = true
                
                
                
                // Add Key and Value to Horizontal Stack
                horizontalStack.addArrangedSubview(keyLabel)
                if indentLevel == 1 {
                    horizontalStack.addArrangedSubview(colonLabel)
                }
                horizontalStack.addArrangedSubview(textView)
//                
                stackView.addArrangedSubview(horizontalStack)
               
               
            case .array(let values):
                if let key = row.key {
                    let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 6), position: indentLevel)
                    stackView.addArrangedSubview(keyLabel) // Ensure key (title) is added
                }
                // Create vertical stack for array values
                let containerView = UIStackView()
                containerView.axis = .vertical
                containerView.spacing = 8
                stackView.addArrangedSubview(containerView)
                
                for (index,value) in values.enumerated() {
                    if let nestedDict = value as? [String: Any] {
                        addNestedDictionary(nestedDict, to: containerView, indentLevel: indentLevel + 1)
                    } else {
                        let currentViewTag = row.elementTags?[index] ?? (row.tag * 10 + index)
                        let textView = createTextView(text: "\(value)", currentTag: currentViewTag)
                        textView.tag = currentViewTag
                        containerView.addArrangedSubview(textView)
                    }
                }
                
                let singleView = SingleValueView(value: "")
                let lastTag = row.elementTags?.last.map { $0 + 1 }
                let fallbackTag = row.tag * 10
                singleView.valueTextView.tag = lastTag ?? fallbackTag
                
                stackView.addArrangedSubview(singleView)
                singleView.configureView(status: encounterStatus)
                
                singleView.addAction = { updatedText, tag in
                    print("\(updatedText)")
                    self.appendNewElementWithInSubSection(tag: tag, newValue: updatedText)
                }
                singleView.addSectionLabel.text = " +  Add   \(row.key ?? "")"
                
            case .object(let dict):
                addNestedDictionary(dict, to: stackView, indentLevel: indentLevel)
                
            case .none:
                print("None")
            }
        }
        
        if let nestedSection = row.section {
            addSectionToUI(nestedSection, indentLevel: indentLevel + 1, encounterStatus: encounterStatus)
        }
    }
    
    private func addNestedDictionary(_ dict: [String: Any], to containerView: UIStackView, indentLevel: Int) {
        for (key, value) in dict {
//             Create a key label for every key
            let keyLabel = createLabel(text: key, bold: true, leftPadding: CGFloat(indentLevel * 4), position: indentLevel)
            containerView.addArrangedSubview(keyLabel)
            
            if let stringValue = value as? String {
                // Key-Value pair in a horizontal stack
                let horizontalStack = UIStackView()
                horizontalStack.axis = .horizontal
                horizontalStack.spacing = 8
                horizontalStack.alignment = .center
                
                let textView = createTextView(text: stringValue, leftPadding: 0, currentTag: 0)
//                textView.tag =
                horizontalStack.addArrangedSubview(textView)
                
                containerView.addArrangedSubview(horizontalStack)
                
            } else if let arrayValue = value as? [String] {
                // Key-Array scenario (fixing missing title issue)
                let containerStack = UIStackView()
                containerStack.axis = .vertical
                containerStack.spacing = 8
                containerView.addArrangedSubview(containerStack)
                
                for text in arrayValue {
                    let textView = createTextView(text: text, leftPadding: CGFloat(indentLevel * 4), currentTag: 0)
                    textView.tag = getUniqueTag()
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
    
    
    
    private func createLabel(text: String, bold: Bool, leftPadding: CGFloat = 0, position: Int) -> UILabel {
        let label = PaddedLabel()
        label.text = text
        label.numberOfLines = 0
        label.font = bold ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 13)
        label.padding = UIEdgeInsets(top: 6, left: leftPadding + 8, bottom: 6, right: 8)
       

        // Ensure the label only takes up required width
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)

        label.textColor = .white
        label.layer.cornerRadius = (position == 0) ? 12 : 0
        let customColor = UIColor(red: 0.365, green: 0.373, blue: 0.937, alpha: 1)
        label.layer.backgroundColor = (position == 0) ? customColor.cgColor : UIColor.clear.cgColor

        return label
    }
    
    
    private func createTextView(text: String, leftPadding: CGFloat = 8,currentTag:Int) -> UITextView {
        var textView = PaddedTextView()
        textView.text = text
        textView.isEditable = true
        textView.font = UIFont.systemFont(ofSize: 12)
//        textView.layer.cornerRadius = 5
//        textView.layer.borderWidth = 1
//        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.isScrollEnabled = false  // Important!
        textView.delegate = self  // Assign delegate
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .clear
        
        textView.padding = UIEdgeInsets(top: 2, left: leftPadding, bottom: 2, right: 8)
        
        // **Set Initial Height Constraint**
        let estimatedHeight = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 40, height: CGFloat.greatestFiniteMagnitude)).height
        let heightConstraint = textView.heightAnchor.constraint(equalToConstant: estimatedHeight)
        heightConstraint.isActive = true
        
        // **Store the constraint in a dictionary for easy access**
        textView.tag = currentTag // Unique identifier
        
        //        textView.tag = ((sectionIndex ?? 0) * 1000) + (rowIndex ?? 0)
        textViewConstraints[textView.tag] = heightConstraint
        
        return textView
    }
    
    
    func updateScrollViewContentSize() {
        DispatchQueue.main.async {
            self.scrollView.layoutIfNeeded()
            self.scrollView.contentSize = self.stackView.frame.size
        }
    }
    
    private func getUniqueTag() -> Int {
        tagCounter += 1
        return tagCounter
    }
    
    //MARK: - Edit Funcationality
    
    /* For pre existing data */
    func updateRowValue(for position: Int, newValue: String) {
        for sectionIndex in 0..<soapSections.count {
            if updateRowValueRecursively(in: &soapSections[sectionIndex].rows, position: position, newValue: newValue) {
                print(soapSections)
                return
            }
        }
    }

   
    private func updateRowValueRecursively(in rows: inout [Row], position: Int, newValue: String) -> Bool {
        for rowIndex in 0..<rows.count {
            
            if let elementTags = rows[rowIndex].elementTags, let index = elementTags.firstIndex(of: position) {
                switch rows[rowIndex].value {
                case .string(_):
                    rows[rowIndex].value = .string(newValue)
                    print("Updated string at position: \(position) inside elementTags with value: \(newValue)")
                case .array(var values):
                    if index < values.count {
                        values[index] = newValue
                        rows[rowIndex].value = .array(values)
                        print("Updated array at index \(index) inside elementTags with value: \(newValue)")
                    } else {
                        print("Error: Index \(index) out of bounds for row with tag \(position)")
                    }
                default:
                    print(" Unsupported value type for elementTags update.")
                }
                return true
            }

           
            if rows[rowIndex].tag == position {
                switch rows[rowIndex].value {
                case .string(_):
                    rows[rowIndex].value = .string(newValue)
                    print(" position: \(position) (row.tag match) with value: \(newValue)")
                case .array(var values):
                    rows[rowIndex].value = .array(values)
                    print(".")
                default:
                    print("")
                }
                return true
            }

            if var section = rows[rowIndex].section {
                var mutableRows = section.rows
                if updateRowValueRecursively(in: &mutableRows, position: position, newValue: newValue) {
                    rows[rowIndex].section?.rows = mutableRows
                    return true
                }
            }
        }
        return false
    }

//MARK: - Adding sub section
    private func appendNewElementWithInSubSection(tag: Int, newValue: String) {
        for sectionIndex in 0..<soapSections.count {
            if addSectionData(in: &soapSections[sectionIndex].rows, position: tag, newValue: newValue) {
                DispatchQueue.main.async {
                    self.updateStackView()
                }
                return
            }
        }
    }
    
//    func addSectionData(in rows: inout [Row], position: Int, newValue: String) -> Bool {
//        for rowIndex in 0..<rows.count {
//            
//            let rowTag = rows[rowIndex].tag
//            let elementTag = rows[rowIndex].elementTags
//        
//                if var elementTags = rows[rowIndex].elementTags, let index = elementTags.firstIndex(of: position - 1 ) {
//                    switch rows[rowIndex].value {
//                    case .string(_):
//                        rows[rowIndex].value = .string(newValue)
//                        print("Updated string at position: \(position) inside elementTags with value: \(newValue)")
//                    case .array(var values):
//                        if index < values.count {
//                            values.append(newValue)
//                            rows[rowIndex].value = .array(values)
//                            
//                            // Generate a new unique tag
//                            let newTag = position
//                            elementTags.append(newTag) // Append new tag
//                            rows[rowIndex].elementTags = elementTags
//                            //
//                            print("Updated array at index \(index) inside elementTags with value: \(newValue)")
//                        } else {
//                            print("Error: Index \(index) out of bounds for row with tag \(position)")
//                        }
//                    default:
//                        print(" Unsupported value type for elementTags update.")
//                    }
//                    return true
//                }
//        }
//        return false
//    }
    
    func addSectionData(in rows: inout [Row], position: Int, newValue: String) -> Bool {
        var referenceTag: Int?

        // Step 1: Find the row with the matching element tag or derive referenceTag if nil
        for rowIndex in 0..<rows.count {
            if let elementTags = rows[rowIndex].elementTags, let index = elementTags.firstIndex(of: position - 1) {
                referenceTag = elementTags[index]
                updateRow(&rows[rowIndex], newValue: newValue, newTag: position)
                return true
            }
        }

        if referenceTag == nil {
            referenceTag = position / 10
        }

        guard let rowIndex = rows.firstIndex(where: { $0.tag == referenceTag }) else {
            print("Error: No row found with tag \(referenceTag!)")
            return false
        }

        updateRow(&rows[rowIndex], newValue: newValue, newTag: position)
        return true
    }

    // Helper function to update row
    private func updateRow(_ row: inout Row, newValue: String, newTag: Int) {
        if row.elementTags == nil {
            row.elementTags = []
        }

        switch row.value {
        case .string(_):
            row.value = .string(newValue)
            print("Updated string inside elementTags with value: \(newValue)")
        case .array(var values):
            values.append(newValue)
            row.value = .array(values)

            // Append new tag
            row.elementTags?.append(newTag)

            print("Updated array for row with tag \(row.tag), added value: \(newValue)")
        default:
            print("Unsupported value type for elementTags update.")
        }
    }




    
    //MARK: - Adding to main sections
    private func appendNewElementInSection(tag: Int, key: String, value: String) {
        for sectionIndex in 0..<soapSections.count {
            if addRowToSection(in: &soapSections, sectionPosition: tag, newKey: key, newValue: value)
            {
                refreshUI()
                return
            }
        }
    }

    private func addRowToSection(in sections: inout [Section], sectionPosition:Int, newKey: String, newValue: String) -> Bool {
        
        guard let sectionIndex = sections.firstIndex(where: { $0.position == sectionPosition }) else { return false }
        
        let nextRowPosition = (sections[sectionIndex].rows.last?.position ?? -1) + 1
        
        let lastTag = (sections[sectionIndex].rows.last?.tag ?? 1000)
        let newTag = lastTag + 1

        let newRow:Row
        if sectionPosition == 0 {
            newRow = Row(
                    position: nextRowPosition,
                    key: newKey,
                    value: .string(newValue),
                    tag: newTag
                )
        } else {
            newRow = Row(
                    position: nextRowPosition,
                    key: newKey,
                    value: .array([newValue]),
                    tag: newTag
                )
        }
        
       
        sections[sectionIndex].rows.append(newRow)
        return true
    }



    private func refreshUI() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        populateUI(encounterStatus: encounterStatus)
    }

    
    private func updateStackView() {
        // Remove all arranged subviews
        for view in stackView.arrangedSubviews {
            stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        // Re-populate UI with updated data
        populateUI(encounterStatus: encounterStatus)
        
        // Ensure layout updates properly
        stackView.layoutIfNeeded()
        scrollView.layoutIfNeeded()
    }
    
    
    @objc func finalizedBtnTapped() {
        self.encounterStatus = "isFinal"
        refreshUI()
    }
    
    @objc func editOrSaveBtnTapped() {
        isEditingMode.toggle()
        
        let newTitle = isEditingMode ? " Edit" : " Save"
        let newImage = UIImage(systemName: isEditingMode ? "pencil" : "checkmark")
        
        editOrSaveBtn.setTitle(newTitle, for: .normal)
        editOrSaveBtn.setImage(newImage, for: .normal)
        
        // if its edit -> show fields or else hide fields
        if newTitle == " Save" {
            self.encounterStatus = ""
            refreshUI()
        } else {
            self.encounterStatus = "isFinal"
            refreshUI()
            let updatedRows = soapSections.compactMap { Row.init(position: 0, key: nil, value: nil,section: $0) }
            let updatedJson = convertRowsToJsonString(rows: updatedRows)
            print(updatedJson)
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        let tag = textView.tag
        let updatedValue = textView.text ?? ""
        print(tag)
        self.updateRowValue(for: tag, newValue: updatedValue)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        preferredMaxLayoutWidth = bounds.width
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
