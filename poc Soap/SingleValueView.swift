//
//  SingleValueView.swift
//  poc Soap
//
//  Created by sagar on 08/02/25.
//

import UIKit

class SingleValueView: UIView {
    
    private let valueTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("➕", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    private let removeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("❌", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    var removeAction: (() -> Void)?
    var addAction: (() -> Void)?

    init(value: String) {
        super.init(frame: .zero)
        valueTextView.text = value
        
        stackView.addArrangedSubview(valueTextView)
        stackView.addArrangedSubview(addButton)
        stackView.addArrangedSubview(removeButton)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Constraints
        NSLayoutConstraint.activate([
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapAdd() {
        addAction?()
    }
    
    @objc private func didTapRemove() {
        removeAction?()
    }
}
