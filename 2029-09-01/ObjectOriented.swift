import Foundation

//3a

struct Transaction {
    var id: String
    var date: Date
    var amount: Double
    var description: String
    var isDebit: Bool
    var isPending: Bool = false
    
    var formattedAmount: String {
        let formatted = String(format: "%.2f", abs(amount))
        return isDebit ? "-$\(formatted)" : "+$\(formatted)"
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    mutating func markAsPending() {
        isPending = true
    }
}

//3b

var t1 = Transaction(
    id: "txn_001",
    date: Date(),
    amount: 2500.00,
    description: "Direct Deposit",
    isDebit: false
)

var t2 = Transaction(
    id: "txn_002",
    date: Date(),
    amount: 45.67,
    description: "Starbucks",
    isDebit: true
)

print(t1.formattedAmount, t1.description)
print(t2.formattedAmount, t2.description)

//3c

var t3 = t1

t3.description = "Modified"

print("t1 description:", t1.description)
print("t3 description:", t3.description)

// t1 is still direct deposit because assigning t1 to t3 creates a serparate copy instead of changing it

//3d
t2.markAsPending()

print("ts pending:", t2.isPending)

//4a

class BankAccount {
    var id: String
    var accountNumber: String
    var balance: Double
    var owner: String
    
    init(
        id: String,
        accountNumber: String,
        owner: String,
        initialBalance: Double = 0.0
    ) {
        self.id = id
        self.accountNumber = accountNumber
        self.owner = owner
        self.balance = initialBalance
    }
    
    func deposit(amount: Double) {
        if amount > 0 {
            balance += amount
        }
    }
    
    func withdraw(amount: Double) -> Bool {
        if amount > 0 && amount <= balance {
            balance -= amount
            return true
        }
        
        return false
    }
    
    func printSummary() {
        print(
            String(
                format: "Account %@ | Owner: %@ | Balance: $%.2f",
                accountNumber,
                owner,
                balance
            )
        )
    }
}

//4b
let checking = BankAccount(
    id: "acc_001",
    accountNumber: "1234567890",
    owner: "Jane Smith",
    initialBalance: 1000.00
)

let savings = BankAccount(
    id: "acc_002",
    accountNumber: "0987654321",
    owner: "Jane Smith",
    initialBalance: 5000.00
)

checking.deposit(amount: 500)
checking.withdraw(amount: 200)

checking.printSummary()
savings.printSummary()

//4c
let checkingRef = checking

checkingRef.deposit(amount: 500)

print("checking balance:", checking.balance)
print("checkingRef balance:", checkingRef.balance)

//both show the same balance, checkingRef and checking point point to the same object BankAccount 

//4d
class PremiumBankAccount: BankAccount {
    var overdraftLimit: Double
    
    init(
        id: String,
        accountNumber: String,
        owner: String,
        initialBalance: Double = 0.0,
        overdraftLimit: Double
    ) {
        self.overdraftLimit = overdraftLimit
        
        super.init(
            id: id,
            accountNumber: accountNumber,
            owner: owner,
            initialBalance: initialBalance
        )
    }
    
    override func withdraw(amount: Double) -> Bool {
        if amount > 0 && amount <= balance + overdraftLimit {
            balance -= amount
            return true
        }
        
        return false
    }
}


//test it
let premium = PremiumBankAccount(
    id: "acc_003",
    accountNumber: "5555555555",
    owner: "Jane Smith",
    initialBalance: 100,
    overdraftLimit: 500
)

let withdrawal1 = premium.withdraw(amount: 400)
print("Withdraw $400:", withdrawal1)
print("Balance:", premium.balance)

let withdrawal2 = premium.withdraw(amount: 800)
print("Withdraw $800:", withdrawal2)
print("Balance:", premium.balance)

//5a 
enum TransactionType: String, CaseIterable {
    case credit
    case debit
    case transfer
    case fee
    
    //  5b
    var displayName: String {
        switch self {
        case .credit:
            return "Credit"
        case .debit:
            return "Debit"
        case .transfer:
            return "Transfer"
        case .fee:
            return "Fee"
        }
    }
}

//5c

enum AccountError {
    case insufficientFunds(available: Double, requested: Double)
    case accountInactive
    case dailyLimitExceeded(limit: Double)
    case invalidAmount
}

func describeError(_ error: AccountError) -> String {
    switch error {
    case .insufficientFunds(let available, let requested):
        return String(
            format: "Insufficient funds. Available: $%.2f, Requested: $%.2f",
            available,
            requested
        )
        
    case .accountInactive:
        return "Account is inactive."
        
    case .dailyLimitExceeded(let limit):
        return String(
            format: "Daily limit exceeded. Limit: $%.2f",
            limit
        )
        
    case .invalidAmount:
        return "Invalid amount."
    }
}


// Test all four cases

print(
    describeError(
        .insufficientFunds(
            available: 1000.00,
            requested: 1500.00
        )
    )
)

print(describeError(.accountInactive))

print(
    describeError(
        .dailyLimitExceeded(limit: 5000.00)
    )
)

print(describeError(.invalidAmount))

//5d

for type in TransactionType.allCases {
    print("\(type.rawValue) → \"\(type.rawValue)\"")
}