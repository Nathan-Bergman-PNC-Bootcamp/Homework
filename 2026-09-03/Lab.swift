import Foundation

enum TransactionType: String, CaseIterable, Codable {
    case credit
    case debit
    case transfer
    case fee

    var isExpense: Bool{
        return self == .debit || self == .fee
    }
}

enum TransactionStatus: String, Codable{
    case pending
    case completed
    case failed
    case cancelled

    var isTerminal: Bool {
        return self == .completed || self == .failed || self == .cancelled
    }
}

struct Transaction: Identifiable, Codable, Equatable, Hashable, Summarizable {

 var id: String = UUID().uuidString
    var date: Date
    var amount: Double
    var description: String
    var type: TransactionType
    var status: TransactionStatus = .completed
    var category: String?
    var merchantName: String?
    
    var formattedAmount: String {
        if type.isExpense {
            return String(format: "-$%.2f", amount)
        } else {
            return String(format: "+$%.2f", amount)
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var resolvedCategory: String {
        return category ?? "Uncategorized"
    }
    
    init(
        date: Date,
        amount: Double,
        description: String,
        type: TransactionType,
        status: TransactionStatus = .completed,
        category: String? = nil,
        merchantName: String? = nil
    ) {
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.status = status
        self.category = category
        self.merchantName = merchantName
    }
    
    var summary: String {
        return "\(formattedAmount) \(description) - \(resolvedCategory)"
    }
}

protocol Summarizable {
    var summary: String { get }
}

extension Summarizable {
    func printSummary() {
        print(summary)
    }
}

protocol AccountOperations {
    func deposit(amount: Double) throws
    func withdraw(amount: Double) throws
    func transfer(amount: Double, to destination: BankAccount) throws
}

enum AccountOperationsError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double, required: Double)
    case accountInactive
    case transferToSameAccount
    case dailyLimitExceeded(limit: Double)
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid amount. The amount must be greater than zero."
            
        case .insufficientFunds(let available, let required):
            return String(
                format: "Insufficient funds. Available: $%.2f, Required: $%.2f",
                available,
                required
            )
            
        case .accountInactive:
            return "Account is inactive."
            
        case .transferToSameAccount:
            return "Cannot transfer money to the same account."
            
        case .dailyLimitExceeded(let limit):
            return String(
                format: "Daily transaction limit exceeded. Limit: $%.2f",
                limit
            )
        }
    }
}

class BankAccount: Identifiable, AccountOperations, Summarizable {
    
    var id: String
    var accountNumber: String
    var accountType: String
    var nickname: String?
    var balance: Double
    var availableBalance: Double
    let currency: String
    let isActive: Bool
    var transactions: [Transaction]
    
    init(
        id: String = UUID().uuidString,
        accountNumber: String,
        accountType: String,
        nickname: String? = nil,
        initialBalance: Double,
        currency: String = "USD",
        isActive: Bool = true
    ) {
        self.id = id
        self.accountNumber = accountNumber
        self.accountType = accountType
        self.nickname = nickname
        self.balance = initialBalance
        self.availableBalance = initialBalance
        self.currency = currency
        self.isActive = isActive
        self.transactions = []
    }
    
    var displayName: String {
        return nickname ?? accountType.capitalized
    }
    
    var maskedAccountNumber: String {
        if accountNumber.count <= 4 {
            return "****" + accountNumber
        }
        
        let lastFour = String(accountNumber.suffix(4))
        return "****" + lastFour
    }
    
    var formattedBalance: String {
        return String(format: "$%.2f", balance)
    }
    
    var recentTransactions: [Transaction] {
        return Array(
            transactions
                .sorted { $0.date > $1.date }
                .prefix(5)
        )
    }
    
    var pendingCount: Int {
        return transactions.filter {
            $0.status == .pending
        }.count
    }
    
    func deposit(amount: Double) throws {
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        balance += amount
        availableBalance = balance
    }
    
    func withdraw(amount: Double) throws {
        guard isActive else {
            throw AccountOperationsError.accountInactive
        }
        
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        guard amount <= availableBalance else {
            throw AccountOperationsError.insufficientFunds(
                available: availableBalance,
                required: amount
            )
        }
        
        balance -= amount
        availableBalance = balance
    }
    
    func transfer(amount: Double, to destination: BankAccount) throws {
        guard isActive && destination.isActive else {
            throw AccountOperationsError.accountInactive
        }
        
        guard amount > 0 else {
            throw AccountOperationsError.invalidAmount
        }
        
        guard id != destination.id else {
            throw AccountOperationsError.transferToSameAccount
        }
        
        guard amount <= availableBalance else {
            throw AccountOperationsError.insufficientFunds(
                available: availableBalance,
                required: amount
            )
        }
        
        balance -= amount
        availableBalance = balance
        
        destination.balance += amount
        destination.availableBalance = destination.balance
    }
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
        
        if transaction.type.isExpense || transaction.type == .transfer {
            balance -= transaction.amount
        } else {
            balance += transaction.amount
        }
        
        availableBalance = balance
    }
    
    var summary: String {
        return "\(displayName) \(maskedAccountNumber) | Balance: \(formattedBalance)"
    }
}

protocol AnalyticsProvider {
    var totalCredits: Double { get }
    var totalDebits: Double { get }
    var netFlow: Double { get }
    var largestTransaction: Transaction? { get }
    
    func monthlyTotal(month: Int, year: Int) -> Double
    func transactionsByCategory() -> [String: [Transaction]]
}

struct AccountAnalytics: AnalyticsProvider {
    
    var transactions: [Transaction]
    
    var totalCredits: Double {
        return transactions
            .filter { !$0.type.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    var totalDebits: Double {
        return transactions
            .filter { $0.type.isExpense }
            .reduce(0) { $0 + $1.amount }
    }
    
    var netFlow: Double {
        return totalCredits - totalDebits
    }
    
    var largestTransaction: Transaction? {
        return transactions.max {
            $0.amount < $1.amount
        }
    }
    
    func monthlyTotal(month: Int, year: Int) -> Double {
        let calendar = Calendar.current
        
        return transactions
            .filter { transaction in
                let components = calendar.dateComponents(
                    [.month, .year],
                    from: transaction.date
                )
                
                return components.month == month &&
                       components.year == year &&
                       transaction.type.isExpense
            }
            .reduce(0) { $0 + $1.amount }
    }
    
    func transactionsByCategory() -> [String: [Transaction]] {
        return Dictionary(
            grouping: transactions,
            by: { $0.resolvedCategory }
        )
    }
}

func reportResults<T: Summarizable>(
    _ items: [T],
    title: String
) {
    print("===\(title)===")
    print("\(items.count) items")
    
    for item in items {
        item.printSummary()
    }
    
    print("===End of \(title)===")
}

func runlabDemo() {
        print("DEMO")

        let checkingAccount = BankAccount(
        accountNumber: "1234567890",
        accountType: "CHECKING",
        nickname: "My Checking",
        initialBalance: 3500.00
    )
    
    let savingsAccount = BankAccount(
        accountNumber: "0987654321",
        accountType: "SAVINGS",
        nickname: "My Savings",
        initialBalance: 12000.00
    )
    
    print("\nAccounts Created")
    print(checkingAccount.summary)
    print(savingsAccount.summary)

    let transaction1 = Transaction(
        date: Date(),
        amount: 2500.00,
        description: "Direct Deposit",
        type: .credit,
        category: "Income",
        merchantName: "Employer"
    )
    
    let transaction2 = Transaction(
        date: Date(),
        amount: 45.67,
        description: "Starbucks",
        type: .debit,
        category: "Food",
        merchantName: "Starbucks"
    )
    
    let transaction3 = Transaction(
        date: Date(),
        amount: 1200.00,
        description: "Rent",
        type: .debit,
        category: "Housing",
        merchantName: "Landlord"
    )
    
    let transaction4 = Transaction(
        date: Date(),
        amount: 25.00,
        description: "Monthly Account Fee",
        type: .fee,
        category: "Fees",
        merchantName: "PNC"
    )
    
    let transaction5 = Transaction(
        date: Date(),
        amount: 500.00,
        description: "Transfer to Savings",
        type: .transfer,
        category: "Transfer",
        merchantName: "PNC"
    )
    
    print("\nAdding Transactions")
    
    checkingAccount.addTransaction(transaction1)
    print("After Direct Deposit: \(checkingAccount.formattedBalance)")
    
    checkingAccount.addTransaction(transaction2)
    print("After Starbucks: \(checkingAccount.formattedBalance)")
    
    checkingAccount.addTransaction(transaction3)
    print("After Rent: \(checkingAccount.formattedBalance)")
    
    checkingAccount.addTransaction(transaction4)
    print("After Fee: \(checkingAccount.formattedBalance)")
    
    checkingAccount.addTransaction(transaction5)
    print("After Transfer: \(checkingAccount.formattedBalance)")
    
    print("\nError Handling")

    do {
        try checkingAccount.withdraw(amount: 10000.00)
    } catch AccountOperationsError.insufficientFunds(
        let available,
        let required
    ) {
        print(
            String(
                format: "Insufficient funds caught. Available: $%.2f, Required: $%.2f",
                available,
                required
            )
        )
    } catch {
        print(error.localizedDescription)
    }
    
    do {
        try checkingAccount.deposit(amount: -100.00)
    } catch AccountOperationsError.invalidAmount {
        print("Invalid amount caught: \(AccountOperationsError.invalidAmount.localizedDescription)")
    } catch {
        print(error.localizedDescription)
    }
    
    do {
        try checkingAccount.transfer(
            amount: 100.00,
            to: checkingAccount
        )
    } catch AccountOperationsError.transferToSameAccount {
        print(
            "Transfer error caught: \(AccountOperationsError.transferToSameAccount.localizedDescription)"
        )
    } catch {
        print(error.localizedDescription)
    }

     let analytics = AccountAnalytics(
        transactions: checkingAccount.transactions
    )
    
    print("\nAnalytics")
    
    print(
        String(
            format: "Total Credits: $%.2f",
            analytics.totalCredits
        )
    )
    
    print(
        String(
            format: "Total Debits: $%.2f",
            analytics.totalDebits
        )
    )
    
    print(
        String(
            format: "Net Flow: $%.2f",
            analytics.netFlow
        )
    )
    
    if let largest = analytics.largestTransaction {
    print(
        "Largest Transaction: \(largest.description) - $\(String(format: "%.2f", largest.amount))"
    )
}
    
    print("\nTransactions by Category:")
    
    let groupedTransactions = analytics.transactionsByCategory()
    
    for (category, transactions) in groupedTransactions {
        print("\(category): \(transactions.count)")
    }

    print()
    
    reportResults(
        checkingAccount.transactions,
        title: "Checking Transactions"
    )
    
    print()
    
    reportResults(
        [checkingAccount, savingsAccount],
        title: "All Accounts"
    )

    print("\nValue vs Reference Semantics")
    
    var transactionCopy = transaction1
    transactionCopy.description = "Modified Description"
    
    print("Original Transaction: \(transaction1.description)")
    print("Copied Transaction: \(transactionCopy.description)")
    
    
    let checkingAlias = checkingAccount
    
    do {
        try checkingAlias.deposit(amount: 100.00)
    } catch {
        print(error.localizedDescription)
    }
    
    print(
        String(
            format: "Original Checking Balance: $%.2f",
            checkingAccount.balance
        )
    )
    
    print(
        String(
            format: "Alias Checking Balance: $%.2f",
            checkingAlias.balance
        )
    )
}

runlabDemo()