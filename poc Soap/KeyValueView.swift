//
//  KeyValueView.swift
//  poc Soap
//
//  Created by sagar on 08/02/25.
//

import UIKit

class KeyValueView: UIView {
    
    private let keyTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
//        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray5
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    private let valueTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16)
//        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .systemGray6
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.lightGray.cgColor
        return textView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillProportionally
        return stackView
    }()
    
    init(key: String, value: String) {
        super.init(frame: .zero)
        keyTextView.text = key
        valueTextView.text = value
        
        stackView.addArrangedSubview(keyTextView)
        stackView.addArrangedSubview(valueTextView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            keyTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 1/3),
            valueTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 2/3)
        ])
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

