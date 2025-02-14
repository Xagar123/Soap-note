//
//  KeyValueView.swift
//  poc Soap
//
//  Created by sagar on 08/02/25.
//

import UIKit

class KeyValueView: UIView, UITextViewDelegate {
    
    let keyTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
//        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
//        textView.isHidden = true
        return textView
    }()
    
    let valueTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
//        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
//        textView.isHidden = true
        return textView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
//        stackView.isHidden = true
        return stackView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("➕", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        button.isHidden = true
        return button
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("❌", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
//        button.isHidden = true
        return button
    }()
    
    let addSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to Hide"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addSectionView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 10  // Rounded corners
        view.layer.masksToBounds = true  // Clip content inside the corners

        // **Shadow for better visibility**
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false  // Allow shadow to extend beyond the view

        return view
    }()

    
    var removeAction: (() -> Void)?
    var addAction: ((String,String, Int) -> Void)?
    

    init(key: String, value: String) {
        super.init(frame: .zero)

        keyTextView.text = key
        valueTextView.text = value

        // **Add addSectionView before stackView**
        
        addSectionView.addSubview(addSectionLabel)
        
        // **Auto Layout for Label**
        NSLayoutConstraint.activate([
            addSectionLabel.centerXAnchor.constraint(equalTo: addSectionView.centerXAnchor),
            addSectionLabel.centerYAnchor.constraint(equalTo: addSectionView.centerYAnchor)
        ])
        
        addSubview(stackView)
        addSubview(addSectionView)

        // Configure addSectionView tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSectionView))
        addSectionView.addGestureRecognizer(tapGesture)
        addSectionView.isUserInteractionEnabled = true  // Enable user interaction

        // StackView Configuration
        stackView.addArrangedSubview(keyTextView)
        stackView.addArrangedSubview(valueTextView)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(removeButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSectionView.translatesAutoresizingMaskIntoConstraints = false

        // **Constraints**
        NSLayoutConstraint.activate([
            // AddSectionView Constraints (Full width, top position)
            addSectionView.topAnchor.constraint(equalTo: topAnchor),
            addSectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            addSectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            addSectionView.heightAnchor.constraint(equalToConstant: 40), // Adjust height as needed

            // StackView Constraints (Below addSectionView)
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            // TextViews Constraints
            keyTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1/3),
            valueTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5),

            // Buttons Constraints
            addButton.widthAnchor.constraint(equalToConstant: 20),
            removeButton.widthAnchor.constraint(equalToConstant: 20)
        ])

        translatesAutoresizingMaskIntoConstraints = false

        // Button Actions
        addButton.addTarget(self, action: #selector(addKeyValue), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(clearData), for: .touchUpInside)

        // TextView Delegates
        keyTextView.delegate = self
        valueTextView.delegate = self
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper
    func configureView(encounterStatus: String) {
        if encounterStatus == "isFinal" {
            finalizedView()
        }
    }
    
    func finalizedView() {
        self.keyTextView.isHidden = true
        self.valueTextView.isHidden = true
        self.stackView.isHidden = true
        self.addButton.isHidden = true
        self.removeButton.isHidden = true
        self.addSectionLabel.isHidden = true
        self.addSectionView.isHidden = true
    }
    
    //MARK: - Selector
    @objc func addKeyValue() {
        
        valueTextView.resignFirstResponder()
        keyTextView.resignFirstResponder()
        
        let newKeyValue = getTextValues()
        
        if newKeyValue.key.isEmpty || newKeyValue.value.isEmpty {
            return
        }
        addAction?(newKeyValue.key, newKeyValue.value,keyTextView.tag)
    }
    
    @objc func clearData() {
        UIView.animate(withDuration: 0.3) {
            self.addSectionView.isHidden.toggle()
        }
    }
    
    @objc private func toggleSectionView() {
        UIView.animate(withDuration: 0.3) {
            self.addSectionView.isHidden.toggle()
        }
    }

    
    func getTextValues() -> (key: String, value: String) {
        return (keyTextView.text.trimmingCharacters(in: .whitespacesAndNewlines), valueTextView.text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        print(textView.tag)
        print("Key and Value")
    }
    
}
