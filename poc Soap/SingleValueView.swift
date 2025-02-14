//
//  SingleValueView.swift
//  poc Soap
//
//  Created by sagar on 08/02/25.
//

import UIKit

class SingleValueView: UIView {
    
    let valueTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
//        textView.isHidden = true
        return textView
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
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
//        stackView.isHidden = true
        return stackView
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
        view.backgroundColor = .systemBlue
        view.layer.cornerRadius = 10  // Rounded corners
        view.layer.masksToBounds = true  // Clip content inside the corners

        // **Shadow for better visibility**
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.masksToBounds = false

        return view
    }()
    
    var removeAction: (() -> Void)?
    var addAction: ((String, Int) -> Void)?

    init(value: String) {
        super.init(frame: .zero)
        valueTextView.text = value
        
        addSectionView.addSubview(addSectionLabel)
        
        // **Auto Layout for Label**
        NSLayoutConstraint.activate([
            addSectionLabel.centerXAnchor.constraint(equalTo: addSectionView.centerXAnchor),
            addSectionLabel.centerYAnchor.constraint(equalTo: addSectionView.centerYAnchor)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSectionView))
        addSectionView.addGestureRecognizer(tapGesture)
        addSectionView.isUserInteractionEnabled = true 
        
        stackView.addArrangedSubview(valueTextView)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(removeButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSectionView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        addSubview(addSectionView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // AddSectionView Constraints (Full width, top position)
            addSectionView.topAnchor.constraint(equalTo: topAnchor),
            addSectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            addSectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            addSectionView.heightAnchor.constraint(equalToConstant: 40), // Adjust height as needed
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            valueTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8),
            addButton.widthAnchor.constraint(equalToConstant: 40),
            removeButton.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Button actions
        addButton.addTarget(self, action: #selector(didTapAdd), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(didTapRemove), for: .touchUpInside)
        self.valueTextView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper
    func configureView(status: String) {
        if status == "isFinal" {
            finalizedView()
        }
    }
    
    func finalizedView() {
        self.stackView.isHidden = true
        self.addSectionView.isHidden = true
        self.valueTextView.isHidden = true
        self.addSectionLabel.isHidden = true
        self.addButton.isHidden = true
        self.removeButton.isHidden = true
    }
    
    
    //MARK: - Selector
    @objc private func didTapAdd() {
       // we are deselecting the textview
        self.valueTextView.resignFirstResponder()
    }
    
    @objc private func didTapRemove() {
        removeAction?()
        UIView.animate(withDuration: 0.3) {
            self.addSectionView.isHidden.toggle()
        }
    }
    
    @objc private func toggleSectionView() {
        UIView.animate(withDuration: 0.3) {
            self.addSectionView.isHidden.toggle()
        }
    }
}

extension SingleValueView: UITextViewDelegate {
   
    func textViewDidEndEditing(_ textView: UITextView) {
        print(textView.tag)
        let textViewTag = textView.tag
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        addAction?(textView.text, textViewTag)
    }
}
