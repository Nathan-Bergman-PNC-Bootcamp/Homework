import Foundation

// Exercise 1
//1a
let appName = "PNC Mobile"

// 1b
var loginAttempts = 0
loginAttempts += 1

//1c
let accountBalance: Double  = 4_250.75

//1d
var interestRate: Double = 0.035

print(appName)
print(loginAttempts)
print(accountBalance)
print(interestRate)

//Excercise 2 

//2a
let firstName = "Jane"
let lastName = "Smith"

//2b
let fullName = "\(firstName) \(lastName)"

//2c
let greeting = "Welcome to PNC Mobile, \(fullName). Your account is active."

//2d
let accountNumber = "1234567890"
let maskedAccount = "****\(String(accountNumber.suffix(4)))"

//2e
print(fullName.count)

print(greeting)
print(maskedAccount)


//Excercise 3 

//3a
let transactionCount = 47
let transactionTotal = 12_309.88

//3b
let averageTransaction = transactionTotal / Double(transactionCount)

//3c
let summary = "\(transactionCount) transactions averaging $\(String(format: "%.2f", averageTransaction)) each"
print(summary)

//3d
let rawInput = "2500"
let parsedAmount = Int(rawInput)

if let amount = parsedAmount {
    print("Parsed amount: \(amount)")
} else {
    print("Invalid input")
}

//Excercise 4

//4a
let balance: Double = 8_500.00

if balance > 25_000 {
    print("Private Banking eligible")
} else if balance > 10_000 {
    print("Preferred client")
} else if balance > 1_000 {
    print("Standard account")
} else {
    print("Low balance alert")
}

//4b
let creditScore = 714

switch creditScore {
case 800...850:
    print("Credit rating: Exceptional")
case 740...799:
    print("Credit rating: Very Good")
case 670...739:
    print("Credit rating: Good")
case 580...669:
    print("Credit rating: Fair")
default:
    print("Credit rating: Poor")
}

//4c
let transactionType = "transfer"

switch transactionType {
case "deposit":
    print("Processing deposit")
case "withdrawal":
    print("Processing withdrawal")
case "transfer":
    print("Processing transfer")
default:
    print("Unknown transaction type: \(transactionType)")
}

//4d
func processWithdrawal(amount: Double, availableBalance: Double) -> String {
    guard amount > 0 else {
        return "Invalid amount"
    }

    guard amount <= availableBalance else {
        return "Insufficient funds. Available: $\(String(format: "%.2f", availableBalance))"
    }

    return "Withdrawal of $\(String(format: "%.2f", amount)) approved"
}

print(processWithdrawal(amount: -50, availableBalance: 1000))
print(processWithdrawal(amount: 2000, availableBalance: 1000))
print(processWithdrawal(amount: 500, availableBalance: 1000))


//Excercise 5

//5a

for num in 1...10 {
    print("7 x \(num) = \(7 * num)")
}


//5b

for num in 1...20 where num % 2 == 0 {
    print(num)
}


//5c

let accounts = ["Checking", "Savings", "Investment", "Credit Card"]

for account in accounts {
    print("• \(account)")
}


//5d

for (index, name) in accounts.enumerated() {
    print("\(index + 1). \(name)")
}


//5e

var attempts = 0
var connected = false

while !connected && attempts < 3 {
    attempts += 1
    print("Connection attempt \(attempts)...")

    if attempts == 3 {
        connected = true
        print("Connected.")
    }
}
