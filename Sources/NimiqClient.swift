import Foundation

public struct Config {
    var scheme: String
    var host: String
    var port: Int
    var user: String
    var password: String
}

struct ResponseError: Decodable {
    var code: Int
    var message: String
}

struct Root<T:Decodable>: Decodable {
    var jsonrpc: String
    var result: T?
    var id: Int
    var error: ResponseError?
}

public enum AccountType: Int, Decodable {
    case basic = 0
    case vesting = 1
    case htlc = 2
}

public struct Account: Decodable {
    var id: String
    var address: String
    var balance: Int
    var type: AccountType
}

public struct VestingContract : Decodable {
    var id: String
    var address: String
    var balance: Int
    var type: AccountType
    var owner: String
    var ownerAddress: String
    var vestingStart: Int
    var vestingStepBlocks: Int
    var vestingStepAmount: Int
    var vestingTotalAmount: Int
}

public struct HashedTimeLockedContract : Decodable {
    var id: String
    var address: String
    var balance: Int
    var type: AccountType
    var sender: String
    var senderAddress: String
    var recipient: String
    var recipientAddress: String
    var hashRoot: String
    var hashAlgorithm: Int
    var hashCount: Int
    var timeout: Int
    var totalAmount: Int
}

enum RawAccount : Decodable {
    case account(Account)
    case vestingContract(VestingContract)
    case hashedTimeLockedContract(HashedTimeLockedContract)
    
    var value: Any {
         switch self {
         case .account(let value):
             return value
         case .vestingContract(let value):
             return value
         case .hashedTimeLockedContract(let value):
             return value
         }
    }
    
    private enum CodingKeys: String, CodingKey {
        case account, vestingContract, hashedTimeLockedContract
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .hashedTimeLockedContract(try container.decode(HashedTimeLockedContract.self))
        } catch {
            do {
                self = .vestingContract(try container.decode(VestingContract.self))
            } catch {
                self = .account(try container.decode(Account.self))
            }
        }
    }
}

public enum ConsensusState: String, Decodable {
    case connecting
    case syncing
    case established
}

public struct Wallet: Decodable {
    var id, address, publicKey: String
    var privateKey: String?
}

public typealias Address = String

public struct OutgoingTransaction {
    var from: Address
    var fromType: AccountType? = .basic
    var to: Address
    var toType: AccountType? = .basic
    var value: Int
    var fee: Int
    var data: String? = nil
}

public typealias Hash = String

public struct Transaction : Decodable {
    var hash: Hash
    var blockHash: Hash?
    var blockNumber: Int?
    var timestamp: Int?
    var confirmations: Int? = 0
    var transactionIndex: Int?
    var from: String
    var fromAddress: Address
    var to: String
    var toAddress: Address
    var value: Int
    var fee: Int
    var data: String? = nil
    var flags: Int
}

public struct Block : Decodable {
    var number: Int
    var hash: Hash
    var pow: Hash
    var parentHash: Hash
    var nonce: Int
    var bodyHash: Hash
    var accountsHash: Hash
    var difficulty: String
    var timestamp: Int
    var confirmations: Int
    var miner: String
    var minerAddress: Address
    var extraData: String
    var size: Int
    var transactions: [Any]
    
    private enum CodingKeys: String, CodingKey {
        case number, hash, pow, parentHash, nonce, bodyHash, accountsHash, difficulty, timestamp, confirmations, miner, minerAddress, extraData, size, transactions
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        number = try container.decode(Int.self, forKey: .number)
        hash = try container.decode(Hash.self, forKey: .hash)
        pow = try container.decode(Hash.self, forKey: .pow)
        parentHash = try container.decode(Hash.self, forKey: .parentHash)
        nonce = try container.decode(Int.self, forKey: .nonce)
        bodyHash = try container.decode(Hash.self, forKey: .bodyHash)
        accountsHash = try container.decode(Hash.self, forKey: .accountsHash)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        timestamp = try container.decode(Int.self, forKey: .timestamp)
        confirmations = try container.decode(Int.self, forKey: .confirmations)
        miner = try container.decode(String.self, forKey: .miner)
        minerAddress = try container.decode(Address.self, forKey: .minerAddress)
        extraData = try container.decode(String.self, forKey: .extraData)
        size = try container.decode(Int.self, forKey: .size)
        do {
            transactions = try container.decode([Transaction].self, forKey: .transactions)
        } catch {
            transactions = try container.decode([Hash].self, forKey: .transactions)
        }
    }
}

public struct BlockTemplateHeader : Decodable {
    var version: Int
    var prevHash: Hash
    var interlinkHash: Hash
    var accountsHash: Hash
    var nBits: Int
    var height: Int
}

public struct BlockTemplateBody : Decodable {
    var hash: Hash
    var minerAddr: String
    var extraData: String
    var transactions: [String]
    var prunedAccounts: [String]
    var merkleHashes: [Hash]
}

public struct BlockTemplate : Decodable {
    var header: BlockTemplateHeader
    var interlink: String
    var body: BlockTemplateBody
    var target: Int
}

public struct TransactionReceipt : Decodable {
    var transactionHash: Hash
    var transactionIndex: Int
    var blockHash: Hash
    var blockNumber: Int
    var confirmations: Int
    var timestamp: Int
}


public struct WorkInstructions : Decodable {
    var data: String
    var suffix: String
    var target: Int
    var algorithm: String
}

public enum LogLevel : String {
    case trace
    case verbose
    case debug
    case info
    case warn
    case error
    case assert
}

public struct MempoolInfo : Decodable {
    var total: Int
    var buckets: [Int]
    var transactionsPerBucket: [Int:Int]
    
    private enum CodingKeys: String, CodingKey {
        case total, buckets
        case bucket10000 = "10000"
        case bucket5000 = "5000"
        case bucket2000 = "2000"
        case bucket1000 = "1000"
        case bucket500 = "500"
        case bucket200 = "200"
        case bucket100 = "100"
        case bucket50 = "50"
        case bucket20 = "20"
        case bucket10 = "10"
        case bucket5 = "5"
        case bucket2 = "2"
        case bucket1 = "1"
        case bucket0 = "0"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Int.self, forKey: .total)
        buckets = try container.decode([Int].self, forKey: .buckets)
        transactionsPerBucket = [Int:Int]()
        for key in container.allKeys {
            guard let intKey = Int(key.stringValue) else {
                continue
            }
            transactionsPerBucket[intKey] = try container.decode(Int.self, forKey: key)
        }
    }
}

enum HashOrTransaction : Decodable {
    case hash(Hash)
    case transaction(Transaction)
    
    var value: Any {
         switch self {
         case .hash(let value):
             return value
         case .transaction(let value):
             return value
         }
    }
    
    private enum CodingKeys: String, CodingKey {
        case hash, transaction
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .transaction(try container.decode(Transaction.self))
        } catch {
            self = .hash(try container.decode(Hash.self))
        }
    }
}

public enum PeerAddressState : Int, Decodable {
    case new = 1
    case established = 2
    case tried = 3
    case failed = 4
    case banned = 5
}

public enum PeerConnectionState : Int, Decodable {
    case new = 1
    case connecting = 2
    case connected = 3
    case negotiating = 4
    case established = 5
    case closed = 6
}

public struct Peer : Decodable {
    var id: String
    var address: String
    var addressState: PeerAddressState
    var connectionState: PeerConnectionState?
    var version: Int?
    var timeOffset: Int?
    var headHash: Hash?
    var latency: Int?
    var rx: Int?
    var tx: Int?
}

public enum PeerStateCommand : String {
    case connect
    case disconnect
    case ban
    case unban
}

public enum PoolConnectionState : Int, Decodable {
    case connected = 0
    case connecting = 1
    case closed = 2
}

public struct SyncStatus : Decodable {
    var startingBlock: Int
    var currentBlock: Int
    var highestBlock: Int
}

enum SyncStatusOrBool : Decodable {
    case syncStatus(SyncStatus)
    case bool(Bool)
    
    var value: Any {
         switch self {
         case .syncStatus(let value):
             return value
         case .bool(let value):
             return value
         }
    }
    
    private enum CodingKeys: String, CodingKey {
        case syncStatus, bool
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .syncStatus(try container.decode(SyncStatus.self))
        } catch {
            self = .bool(try container.decode(Bool.self))
        }
    }
}

public class NimiqClient {
    
    private var id: Int = 0
    
    private let url: String
    
    private let session: URLSession
    
    public enum Error: Swift.Error, Equatable {
        case wrongFormat(_ message: String)
        case badMethodCall(_ message: String)
    }
    
    convenience init(config c: Config) {
        self.init(scheme: c.scheme, user: c.user, password: c.password, host: c.host, port: c.port)
    }
    
    init(scheme: String, user: String, password: String, host: String, port: Int, session: URLSession? = nil){
        self.url = "\(scheme)://\(user):\(password)@\(host):\(port)"
        if session != nil {
            self.session = session!
        } else {
            self.session = URLSession.shared
        }
    }
    
    private func fetch<T:Decodable>(method: String, params: [Any]) throws -> T? {
        var responseObject: Root<T>? = nil
        var clientError: NimiqClient.Error? = nil

        //Make JSON to send to send to server
        let callObject:[String:Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": id
        ]

        let data = try JSONSerialization.data(withJSONObject: callObject, options: [])
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("close", forHTTPHeaderField: "Connection")

        let semaphore = DispatchSemaphore(value: 0)
                    
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            // Serialize the data into an object
            do {
                responseObject = try JSONDecoder().decode(Root<T>.self, from: data! )
                
            } catch {
                clientError = NimiqClient.Error.wrongFormat(error.localizedDescription)
            }
            
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        
        if clientError != nil {
            throw clientError!
        }
        
        if let error = responseObject?.error {
            throw NimiqClient.Error.badMethodCall("\(error.message) (Code: \(error.code)")
        }
        
        self.id = self.id + 1
        
        return responseObject?.result
    }
    
    public func accounts() throws -> [Any]? {
        let result: [RawAccount] = try fetch(method: "accounts", params: [])!
        var converted: [Any] = [Any]()
        for rawAccount in result {
            converted.append(rawAccount.value)
        }
        return converted
    }
    
    public func blockNumber() throws -> Int? {
        return try fetch(method: "blockNumber", params: [])
    }
    
    public func consensus() throws -> ConsensusState? {
        return try fetch(method: "consensus", params: [])
    }
    
    public func constant(constant: String, value: Int? = nil) throws -> Int? {
        var params:[Any] = [constant]
        if value != nil {
            params.append(value!)
        }
        return try fetch(method: "constant", params: params)
    }
    
    public func createAccount() throws -> Wallet? {
        return try fetch(method: "createAccount", params: [])
    }
    
    public func createRawTransaction(transaction: OutgoingTransaction) throws -> String? {
        let params:[String:Any?] = [
            "from": transaction.from,
            "fromType": transaction.fromType?.rawValue,
            "to": transaction.to,
            "toType": transaction.toType?.rawValue,
            "value": transaction.value,
            "fee": transaction.fee,
            "data": transaction.data
        ]
        return try fetch(method: "createRawTransaction", params: [params])
    }
    
    public func getAccount(account: Address) throws -> Any? {
        let result: RawAccount = try fetch(method: "getAccount", params: [account])!
        return result.value
    }

    public func getBalance(account: Address) throws -> Int? {
        return try fetch(method: "getBalance", params: [account])
    }
    
    public func getBlockByHash(hash: Hash, fullTransactions: Bool = false) throws -> Block? {
        return try fetch(method: "getBlockByHash", params: [hash, fullTransactions])
    }
    
    public func getBlockByNumber(number: Int, fullTransactions: Bool = false) throws -> Block? {
        return try fetch(method: "getBlockByNumber", params: [number, fullTransactions])
    }
    
    public func getBlockTemplate(address: Address? = nil, extraData: String = "") throws -> BlockTemplate? {
        var params: [Any] = [Any]()
        if address != nil {
            params.append(address!)
            params.append(extraData)
        }
        return try fetch(method: "getBlockTemplate", params: params)

    }
    
    public func getBlockTransactionCountByHash(hash: Hash) throws -> Int? {
        return try fetch(method: "getBlockTransactionCountByHash", params: [hash])
    }

    public func getBlockTransactionCountByNumber(number: Int) throws -> Int? {
        return try fetch(method: "getBlockTransactionCountByNumber", params: [number])
    }
    
    public func getTransactionByBlockHashAndIndex(hash: Hash, index: Int) throws -> Transaction? {
        return try fetch(method: "getTransactionByBlockHashAndIndex", params: [hash, index])
    }
    
    public func getTransactionByBlockNumberAndIndex(number: Int, index: Int) throws -> Transaction? {
        return try fetch(method: "getTransactionByBlockNumberAndIndex", params: [number, index])
    }
    
    public func getTransactionByHash(hash: Hash) throws -> Transaction? {
        return try fetch(method: "getTransactionByHash", params: [hash])
    }
    
    public func getTransactionReceipt(hash: Hash) throws -> TransactionReceipt? {
        return try fetch(method: "getTransactionReceipt", params: [hash])
    }
    
    public func getTransactionsByAddress(address: Address, numberOfTransactions: Int = 1000) throws -> [Transaction]? {
        return try fetch(method: "getTransactionsByAddress", params: [address, numberOfTransactions])
    }
    
    public func getWork(address: Address? = nil, extraData: String = "") throws -> WorkInstructions? {
        var params: [Any] = [Any]()
        if address != nil {
            params.append(address!)
            params.append(extraData)
        }
        return try fetch(method: "getWork", params: params)
    }
    
    public func hashrate() throws -> Float? {
        return try fetch(method: "hashrate", params: [])
    }
    
    public func log(tag: String, level: LogLevel) throws -> Bool? {
        return try fetch(method: "log", params: [tag, level.rawValue])
    }
    
    public func mempool() throws -> MempoolInfo? {
        return try fetch(method: "mempool", params: [])
    }
    
    public func mempoolContent(fullTransactions: Bool = false) throws -> [Any]? {
        let result: [HashOrTransaction] = try fetch(method: "mempoolContent", params: [fullTransactions])!
        var converted: [Any] = [Any]()
        for transaction in result {
            converted.append(transaction.value)
        }
        return converted
    }
    
    public func minerAddress() throws -> String? {
        return try fetch(method: "minerAddress", params: [])
    }
    
    public func minerThreads(threads: Int? = nil) throws -> Int? {
        var params: [Int] = [Int]()
        if threads != nil {
            params.append(threads!)
        }
        return try fetch(method: "minerThreads", params: params)
    }
    
    public func minFeePerByte(fee: Int? = nil) throws -> Int? {
        var params: [Int] = [Int]()
        if fee != nil {
            params.append(fee!)
        }
        return try fetch(method: "minFeePerByte", params: params)
    }
    
    public func mining(state: Bool? = nil) throws -> Bool? {
        var params: [Bool] = [Bool]()
        if state != nil {
            params.append(state!)
        }
        return try fetch(method: "mining", params: params)
    }
    
    public func peerCount() throws -> Int? {
        return try fetch(method: "peerCount", params: [])
    }
    
    public func peerList() throws -> [Peer]? {
        return try fetch(method: "peerList", params: [])
    }
    
    public func peerState(address: String, command: PeerStateCommand? = nil) throws -> Peer? {
        var params: [Any] = [Any]()
        params.append(address)
        if let commandString = command?.rawValue  {
            params.append(commandString)
        }
        return try fetch(method: "peerState", params: params)
    }
    
    public func pool(address: Any? = nil) throws -> String? {
        var params: [Any] = [Any]()
        if let addressString = address as? String {
            params.append(addressString)
        } else if let addressBool = address as? Bool {
            params.append(addressBool)
        }
        return try fetch(method: "pool", params: params)
    }
    
    public func poolConfirmedBalance() throws -> Int? {
        return try fetch(method: "poolConfirmedBalance", params: [])
    }
    
    public func poolConnectionState() throws -> PoolConnectionState? {
        return try fetch(method: "poolConnectionState", params: [])
    }
    
    public func sendRawTransaction(transaction: String) throws -> Hash? {
        return try fetch(method: "sendRawTransaction", params: [transaction])
    }
    
    public func sendTransaction(transaction: OutgoingTransaction) throws -> Hash? {
        let params:[String:Any?] = [
            "from": transaction.from,
            "fromType": transaction.fromType?.rawValue,
            "to": transaction.to,
            "toType": transaction.toType?.rawValue,
            "value": transaction.value,
            "fee": transaction.fee,
            "data": transaction.data
        ]
        return try fetch(method: "sendTransaction", params: [params])
    }

    @discardableResult public func submitBlock(_ block: String) throws -> String? {
        return try fetch(method: "submitBlock", params: [block])
    }
    
    public func syncing() throws -> Any? {
        let result: SyncStatusOrBool = try fetch(method: "syncing", params: [])!
        return result.value
    }
    
    public func getRawTransactionInfo(transaction: String) throws -> Transaction? {
        return try fetch(method: "getRawTransactionInfo", params: [transaction])
    }
    
    public func transactionsPerBucket(transaction: String) throws -> Transaction? {
        return try fetch(method: "transactionsPerBucket", params: [transaction])
    }
    
    public func resetConstant(constant: String) throws -> Int? {
        return try fetch(method: "constant", params: [constant, "reset"])
    }
}
