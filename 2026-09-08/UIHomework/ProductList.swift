//
//  ProductList.swift
//  UIHomework
//
//  Created by Nathan Bergman on 9/8/26.
//

import SwiftUI

struct ProductList: View {

    @State private var products: [Product] = []

    var body: some View {
        NavigationStack {
            List(products) { product in

                NavigationLink {
                    ProductDetails(product: product)
                } label: {
                    VStack(alignment: .leading) {
                        Text(product.name)
                            .font(.headline)

                        Text(product.color)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Products")
            .task {
                products = await loadProducts()
            }
        }
    }

    func loadProducts() async -> [Product] {
        return [
            Product(
                id: 1,
                name: "iPhone",
                productNumber: "FDSF374F",
                color: "Black",
                listPrice: 1299.99
            ),

            Product(
                id: 2,
                name: "iPhone",
                productNumber: "FSF6D7F7D",
                color: "Red",
                listPrice: 999.99
            ),

            Product(
                id: 3,
                name: "iPhone",
                productNumber: "df78se39f",
                color: "Blue",
                listPrice: 1499.99
            ),

            Product(
                id: 4,
                name: "Airpods",
                productNumber: "FJ7F87HJ8",
                color: "White",
                listPrice: 99.99
            )
        ]
    }
}
