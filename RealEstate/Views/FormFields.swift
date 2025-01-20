//
//  FormFields.swift
//  RealEstate
//
//  Created by Raphael PIERRE on 20.01.2025.
//

import SwiftUI

struct TextFormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    let icon: String?
    
    init(label: String, placeholder: String, text: Binding<String>, isSecure: Bool = false, icon: String? = nil) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.isSecure = isSecure
        self.icon = icon
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let icon = icon {
                Label(label, systemImage: icon)
                    .foregroundColor(Theme.textWhite)
                    .font(Theme.Typography.body)
            } else {
                Text(label)
                    .font(Theme.Typography.body)
                    .foregroundColor(Theme.textWhite)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .modernTextField()
            } else {
                TextField(placeholder, text: $text)
                    .modernTextField()
            }
        }
    }
}

struct NumericFormField<T: Numeric>: View {
    let label: String
    let icon: String
    @Binding var value: T
    let isCurrency: Bool
    
    init(_ label: String, value: Binding<T>, icon: String, isCurrency: Bool = false) {
        self.label = label
        self.icon = icon
        self.isCurrency = isCurrency
        _value = value
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(label, systemImage: icon)
                .foregroundColor(Theme.textWhite)
                .font(Theme.Typography.body)
            
            Group {
                if isCurrency, let doubleValue = value as? Double {
                    TextField("", value: $value as! Binding<Double>, format: .currency(code: "USD"))
                        .modernTextField()
                } else if let intValue = value as? Int {
                    TextField("", value: $value as! Binding<Int>, format: .number)
                        .modernTextField()
                } else if let doubleValue = value as? Double {
                    TextField("", value: $value as! Binding<Double>, format: .number)
                        .modernTextField()
                }
            }
        }
    }
}

#Preview {
    VStack {
        TextFormField(
            label: "Email",
            placeholder: "Enter your email",
            text: .constant(""),
            icon: "envelope.fill"
        )
        
        NumericFormField(
            "Price",
            value: .constant(0.0),
            icon: "dollarsign.circle.fill",
            isCurrency: true
        )
        
        NumericFormField(
            "Count",
            value: .constant(0),
            icon: "number.circle.fill"
        )
    }
    .padding()
    .background(Theme.backgroundBlack)
}