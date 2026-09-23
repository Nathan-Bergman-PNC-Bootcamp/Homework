//
//  ProductDetails.swift
//  UIHomework
//
//  Created by Nathan Bergman on 9/8/26.
//

import SwiftUI

struct ProductDetails: View {
    let product: Product

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            Text(product.name)
                .font(.largeTitle)
                .bold()

            Text("ID: \(product.id)")

            Text("Product Number: \(product.productNumber)")

            Text("Color: \(product.color)")

            Text("List Price: $\(product.listPrice, specifier: "%.2f")")

            Spacer()
        }
        .padding()
        .navigationTitle("Product Details")
    }
}
