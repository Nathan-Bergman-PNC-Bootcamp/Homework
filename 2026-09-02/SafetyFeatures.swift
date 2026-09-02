import Foundation
//1a
protocol Displayable {
    var displayDescription: String { get }
    func printDetails()
}
//1b
extension Displayable {
    func printDetails() {
        print(displayDescription)
    }
}

//1c
struct Transaction: Displayable {
    var id: String
    var date: Date
    var amount: Double
    var description: String
    var isDebit: Bool
    
    var displayDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        
        let formattedAmount = String(
            format: "%@$%.2f",
            isDebit ? "-" : "+",
            abs(amount)
        )
        
        return "\(formatter.string(from: date)) \(description): \(formattedAmount)"
    }
}

// Test 
let transaction1 = Transaction(
    id: "T001",
    date: Date(),
    amount: 2500.00,
    description: "Direct Deposit",
    isDebit: false
)

transaction1.printDetails()


//1d
func printAll(items: [Displayable]) {
    for item in items {
        item.printDetails()
    }
}

let transaction2 = Transaction(
    id: "T002",
    date: Date(),
    amount: 45.67,
    description: "Starbucks",
    isDebit: true
)

let transaction3 = Transaction(
    id: "T003",
    date: Date(),
    amount: 1200.00,
    description: "Rent",
    isDebit: true
)

let transactions: [Displayable] = [
    transaction1,
    transaction2,
    transaction3
]

printAll(items: transactions)


//2a

protocol AccountDataSource {
    func fetchBalance(for accountId: String) -> Double
    func fetchTransactionCount(for accountId: String) -> Int
}


//  2b
struct MockAccountDataSource: AccountDataSource {
    
    func fetchBalance(for accountId: String) -> Double {
        return 4250.75
    }
    
    func fetchTransactionCount(for accountId: String) -> Int {
        return 47
    }
}

//2c
struct LiveAccountDataSource: AccountDataSource {
    
    func fetchBalance(for accountId: String) -> Double {
        return Double.random(in: 100...50_000)
    }
    
    func fetchTransactionCount(for accountId: String) -> Int {
        return Int.random(in: 1...500)
    }
}


// 2d
class AccountDashboard {
    let dataSource: AccountDataSource
    
    init(dataSource: AccountDataSource) {
        self.dataSource = dataSource
    }
    
    func showSummary(for accountId: String) {
        let balance = dataSource.fetchBalance(for: accountId)
        let transactionCount = dataSource.fetchTransactionCount(for: accountId)
        
        print(
            String(
                format: "Account %@: Balance $%.2f | Transactions: %d",
                accountId,
                balance,
                transactionCount
            )
        )
    }
}

let mockDashboard = AccountDashboard(
    dataSource: MockAccountDataSource()
)

let liveDashboard = AccountDashboard(
    dataSource: LiveAccountDataSource()
)

mockDashboard.showSummary(for: "ACC-001")
liveDashboard.showSummary(for: "ACC-002")


//Part B

//3a

class Customer {
    let name: String
    var account: Account?
    
    init(name: String) {
        self.name = name
    }
    
    deinit {
        print("Customer \(name) deallocated")
    }
}


class Account {
    let number: String
    weak var owner: Customer?
    
    init(number: String) {
        self.number = number
    }
    
    deinit {
        print("Account \(number) deallocated")
    }
}


do {
    let customer = Customer(name: "Jane")
    let account = Account(number: "ACC-001")
    
    customer.account = account
    account.owner = customer
}


//3b

class TransactionProcessor {
    let accountId: String
    var onComplete: (() -> Void)?
    
    init(accountId: String) {
        self.accountId = accountId
    }
    
    deinit {
        print("TransactionProcessor \(accountId) deallocated")
    }
    
    func startProcessing() {
        onComplete = { [weak self] in
            guard let self = self else {
                return
            }
            
            print("Processing complete for \(self.accountId)")
        }
    }
    
    func complete() {
        onComplete?()
    }
}


do {
    let processor = TransactionProcessor(accountId: "ACC-001")
    processor.startProcessing()
    processor.complete()
}


//part C

struct Address {
    let street: String
    let city: String
    let zip: String?
}


struct UserProfile {
    let name: String
    var address: Address?
}


let user = UserProfile(
    name: "Jane Smith",
    address: Address(
        street: "123 Main St",
        city: "Columbus",
        zip: "43001"
    )
)

let userNoAddress = UserProfile(
    name: "Bob",
    address: nil
)


// 4a

print("ZIP: \(user.address?.zip ?? "No ZIP available")")
print("ZIP: \(userNoAddress.address?.zip ?? "No ZIP available")")


//4b

func transfer(
    from sourceId: String?,
    to destId: String?,
    amount: Double?
) {
    if let sourceId = sourceId,
       let destId = destId,
       let amount = amount,
       amount > 0 {
        
        print(
            String(
                format: "Transfer $%.2f from %@ to %@ approved",
                amount,
                sourceId,
                destId
            )
        )
    } else {
        print("Transfer failed: missing required fields")
    }
}


transfer(
    from: "ACC-001",
    to: "ACC-002",
    amount: 500.0
)

transfer(
    from: nil,
    to: "ACC-002",
    amount: 500.0
)

transfer(
    from: "ACC-001",
    to: "ACC-002",
    amount: nil
)


// 4c

let rawBalanceString: String? = "4250.75"
let rawInvalidString: String? = "abc"
let nilString: String? = nil

let formattedBalance =
    rawBalanceString
        .flatMap { Double($0) }
        .map { String(format: "$%.2f", $0) }

let formattedInvalid =
    rawInvalidString
        .flatMap { Double($0) }
        .map { String(format: "$%.2f", $0) }

let formattedNil =
    nilString
        .flatMap { Double($0) }
        .map { String(format: "$%.2f", $0) }

print("rawBalanceString → \(String(describing: formattedBalance))")
print("rawInvalidString → \(String(describing: formattedInvalid))")
print("nilString → \(String(describing: formattedNil))")


//4d

let apiURL = URL(string: "https://api.pnc.com/v1")!

// never use force unwrap user input because the string might not
// be a valid URL. If it returns nil, using ! would
// cause the program to crash.
//
// 
// use let or guard let
// 
// if let userURL = URL(string: userInputString) {
//     print(userURL)
// }


//part d


//5a

enum TransferError: LocalizedError {
    case invalidAmount
    case insufficientFunds(available: Double)
    case accountNotFound(id: String)
    case dailyLimitExceeded(limit: Double, attempted: Double)
    case networkUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidAmount:
            return "Invalid transfer amount."
            
        case .insufficientFunds(let available):
            return String(
                format: "Insufficient funds. Available: $%.2f",
                available
            )
            
        case .accountNotFound(let id):
            return "Account not found: \(id)"
            
        case .dailyLimitExceeded(let limit, let attempted):
            return String(
                format: "Daily limit exceeded. Limit: $%.2f | Attempted: $%.2f",
                limit,
                attempted
            )
            
        case .networkUnavailable:
            return "Network unavailable. Please try again later."
        }
    }
}


// 5b

func executeTransfer(
    amount: Double,
    fromBalance: Double,
    toAccountId: String,
    dailyUsed: Double,
    dailyLimit: Double
) throws -> String {
    
    if amount <= 0 {
        throw TransferError.invalidAmount
    }
    
    if toAccountId.isEmpty {
        throw TransferError.accountNotFound(id: toAccountId)
    }
    
    if amount > fromBalance {
        throw TransferError.insufficientFunds(
            available: fromBalance
        )
    }
    
    if dailyUsed + amount > dailyLimit {
        throw TransferError.dailyLimitExceeded(
            limit: dailyLimit,
            attempted: dailyUsed + amount
        )
    }
    
    if toAccountId == "ERR_NET" {
        throw TransferError.networkUnavailable
    }
    
    return String(
        format: "Transfer of $%.2f to account %@ complete",
        amount,
        toAccountId
    )
}


//5c

do {
    let result = try executeTransfer(
        amount: -100,
        fromBalance: 5000,
        toAccountId: "ACC-002",
        dailyUsed: 0,
        dailyLimit: 5000
    )
    
    print(result)
    
} catch let error as TransferError {
    print(error.errorDescription ?? "Unknown transfer error")
}


do {
    let result = try executeTransfer(
        amount: 6000,
        fromBalance: 1000,
        toAccountId: "ACC-002",
        dailyUsed: 0,
        dailyLimit: 10_000
    )
    
    print(result)
    
} catch let error as TransferError {
    print(error.errorDescription ?? "Unknown transfer error")
}


do {
    let result = try executeTransfer(
        amount: 100,
        fromBalance: 5000,
        toAccountId: "",
        dailyUsed: 0,
        dailyLimit: 5000
    )
    
    print(result)
    
} catch let error as TransferError {
    print(error.errorDescription ?? "Unknown transfer error")
}


do {
    let result = try executeTransfer(
        amount: 2000,
        fromBalance: 5000,
        toAccountId: "ACC-002",
        dailyUsed: 4000,
        dailyLimit: 5000
    )
    
    print(result)
    
} catch let error as TransferError {
    print(error.errorDescription ?? "Unknown transfer error")
}


do {
    let result = try executeTransfer(
        amount: 100,
        fromBalance: 5000,
        toAccountId: "ERR_NET",
        dailyUsed: 0,
        dailyLimit: 5000
    )
    
    print(result)
    
} catch let error as TransferError {
    print(error.errorDescription ?? "Unknown transfer error")
}


do {
    let result = try executeTransfer(
        amount: 500,
        fromBalance: 5000,
        toAccountId: "ACC-002",
        dailyUsed: 1000,
        dailyLimit: 5000
    )
    
    print(result)
    
} catch let error as TransferError {
    print(error.errorDescription ?? "Unknown transfer error")
}


//5d

let failedResult = try? executeTransfer(
    amount: -100,
    fromBalance: 5000,
    toAccountId: "ACC-002",
    dailyUsed: 0,
    dailyLimit: 5000
)

print(failedResult ?? "Transfer failed")


let successfulResult = try? executeTransfer(
    amount: 500,
    fromBalance: 5000,
    toAccountId: "ACC-002",
    dailyUsed: 0,
    dailyLimit: 5000
)

print(successfulResult ?? "Transfer failed")


//part E



// 6a

func printFirst<T>(_ array: [T]) {
    if let first = array.first {
        print(first)
    } else {
        print("Array is empty")
    }
}


printFirst([1, 2, 3])
printFirst(["Apple", "Banana", "Orange"])
printFirst([1.5, 2.5, 3.5])
printFirst([Int]())


//6b

struct Stack<Element> {
    private var items: [Element] = []
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element? {
        return items.popLast()
    }
    
    var top: Element? {
        return items.last
    }
    
    var isEmpty: Bool {
        return items.isEmpty
    }
    
    var count: Int {
        return items.count
    }
}


// Test 

var transactionStack = Stack<Double>()

transactionStack.push(250.00)
transactionStack.push(45.67)
transactionStack.push(1200.00)

print("Popped: \(transactionStack.pop()!)")
print("Top: \(transactionStack.top!)")
print("Count: \(transactionStack.count)")


//6c

func findLargest<T: Comparable>(_ array: [T]) -> T? {
    return array.max()
}


print("Largest Int: \(findLargest([10, 20, 5, 30, 15])!)")
print("Largest Double: \(findLargest([1.5, 7.2, 3.8, 2.1])!)")
print("Largest String: \(findLargest(["Apple", "Zebra", "Banana"])!)")