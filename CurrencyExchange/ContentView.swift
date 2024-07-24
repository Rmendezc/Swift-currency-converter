//
//  ContentView.swift
//  CurrencyExchange
//
//  Created by Rudy  Mendez on 7/23/24.
//

import SwiftUI

struct ContentView: View {
    @State private var inputAmount: String = ""
    @State private var outputAmount: String = ""
    @State private var selectedCurrencyFrom = "USD"
    @State private var selectedCurrencyTo = "EUR"
    let currencies = ["USD", "EUR", "GBP", "JPY", "CAD"]
    
    var body: some View {
        VStack {
            TextField("Enter amount", text: $inputAmount)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.decimalPad)

            Picker("From", selection: $selectedCurrencyFrom) {
                ForEach(currencies, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Picker("To", selection: $selectedCurrencyTo) {
                ForEach(currencies, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()

            Button(action: {
                convertCurrency()
            }) {
                Text("Convert")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }

            Text("Converted amount: \(outputAmount)")
                .padding()
        }
        .padding()
    }
    
    func convertCurrency() {
        let trimmedInput = inputAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if the input is a valid number
        guard let amount = Double(trimmedInput) else {
            outputAmount = "Invalid input"
            return
        }
        
        fetchExchangeRate(from: selectedCurrencyFrom, to: selectedCurrencyTo) { rate in
            DispatchQueue.main.async {
                if let rate = rate {
                    let convertedAmount = amount * rate
                    outputAmount = String(format: "%.2f", convertedAmount)
                } else {
                    outputAmount = "Conversion failed"
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

func fetchExchangeRate(from: String, to: String, completion: @escaping (Double?) -> Void) {
    let urlString = "https://api.example.com/exchange?from=\(from)&to=\(to)"
    guard let url = URL(string: urlString) else {
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(nil)
            return
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            if let rate = json?["rate"] as? Double {
                completion(rate)
            } else {
                completion(nil)
            }
        } catch {
            completion(nil)
        }
    }
    
    task.resume()
}
