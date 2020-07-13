import Foundation

// used for convenience initializer
public struct Config {
    let scheme: String
    let host: String
    let port: Int
    let user: String
    let password: String
}

struct Root<T:Decodable>: Decodable {
    let jsonrpc: String
    let result: T
    let id: Int
}

public struct Account: Decodable {
    let id, address: String
    let balance, type: Int
}

public struct Wallet: Decodable {
    let id, address, publicKey: String
    let privateKey: String?
}

public typealias Address = String

public struct OutgoingTransaction {
    let from: Address
    let fromType: Int? = nil
    let to: Address
    let toType: Int? = nil
    let value: Int
    let fee: Int
    let data: String? = nil
}

public typealias Hash = String

public struct Transaction : Decodable {
    let hash: Hash
    let blockHash: Hash?
    let blockNumber: Int?
    let timestamp: Int?
    let confirmations: Int?
    let transactionIndex: Int?
    let from: String
    let fromAddress: Address
    let to: String
    let toAddress: Address
    let value: Int
    let fee: Int
    let data: String?
    let flags: Int
}

public struct Block : Decodable {
    let number: Int
    let hash: Hash
    let pow: Hash
    let parentHash: Hash
    let nonce: Int
    let bodyHash: Hash
    let accountsHash: Hash
    let difficulty: String
    let timestamp: Int
    let confirmations: Int
    let miner: String
    let minerAddress: Address
    let extraData: String
    let size: Int
    let transactions: [Any]
    
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
        } catch DecodingError.typeMismatch {
            transactions = try container.decode([Hash].self, forKey: .transactions)
        }
    }
}

public struct BlockTemplateHeader : Decodable {
    let version: Int
    let prevHash: Hash
    let interlinkHash: Hash
    let accountsHash: Hash
    let nBits: Int
    let height: Int
}

public struct BlockTemplateBody : Decodable {
    let hash: Hash
    let minerAddr: String
    let extraData: String
    let transactions: [String]
    let prunedAccounts: [String]
    let merkleHashes: [Hash]
}

public struct BlockTemplate : Decodable {
    let header: BlockTemplateHeader
    let interlink: String
    let body: BlockTemplateBody
    let target: Int
}

public struct TransactionReceipt : Decodable {
    let transactionHash: Hash
    let transactionIndex: Int
    let blockHash: Hash
    let blockNumber: Int
    let confirmations: Int
    let timestamp: Int
}

public struct WorkInstructions : Decodable {
    let data: String
    let suffix: String
    let target: Int
    let algorithm: String
}

public enum LogLevel : String {
    case trace = "trace"
    case verbose = "verbose"
    case debug = "debug"
    case info = "info"
    case warn = "warn"
    case error = "error"
    case assert = "assert"
}

public struct MempoolInfo : Decodable {
    let total: Int
    let buckets: [Int]
    var transactions: [Int:Int]
    
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
        transactions = [Int:Int]()
        for key in container.allKeys {
            guard let intKey = Int(key.stringValue) else {
                continue
            }
            transactions[intKey] = try container.decode(Int.self, forKey: key)
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
        } catch DecodingError.typeMismatch {
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
    let id: String
    let address: String
    let addressState: PeerAddressState
    let connectionState: PeerConnectionState?
    let version: Int?
    let timeOffset: Int?
    let headHash: Hash?
    let latency: Int?
    let rx: Int?
    let tx: Int?
}

public enum PoolConnectionState : Int, Decodable {
    case connected = 0
    case connecting = 1
    case closed = 2
}

public struct SyncStatus : Decodable {
    let startingBlock: Int
    let currentBlock: Int
    let highestBlock: Int
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
        } catch DecodingError.typeMismatch {
            self = .bool(try container.decode(Bool.self))
        }
    }
}

public class NimiqJSONRPCClient {
    
    private var id: Int = 0
    
    private let url: String
    
    private let session: URLSession
        
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
    
    private func fetch<T:Decodable>(method: String, params: [Any], completionHandler: ((_ result: T?, _ error: Error?) -> Void)? = nil) -> T? {
        var result: T? = nil

        //Make JSON to send to send to server
        let json:[String:Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": id
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("close", forHTTPHeaderField: "Connection")

            var semaphore: DispatchSemaphore? = nil
            
            if completionHandler == nil {
                semaphore = DispatchSemaphore(value: 0)
            }
                        
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                // Check the response
                //print(response)
                
                // Serialize the data into an object
                do {
                    let json = try JSONDecoder().decode(Root<T?>.self, from: data! )
                    self.id = self.id + 1
                    result = json.result
                    
                } catch {
                    let string = String(bytes: data!, encoding: String.Encoding.utf8)
                    print("Response: \(string!)")
                    print("Error: \(error)")
                }
                
                if completionHandler == nil {
                    semaphore!.signal()
                } else {
                    completionHandler!(result, error)
                }
            })
            task.resume()
            if completionHandler == nil {
                semaphore!.wait()
            }
        } catch {
            
        }
        
        return result
    }
    
    @discardableResult public func accounts(completionHandler: ((_ result: [Account]?, _ error: Error?) -> Void)? = nil) -> [Account]? {
        return fetch(method: "accounts", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func blockNumber(completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        return fetch(method: "blockNumber", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func consensus(completionHandler: ((_ result: String?, _ error: Error?) -> Void)? = nil) -> String? {
        return fetch(method: "consensus", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func constant(constant: String, value: Int? = nil, completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        var params:[Any] = [constant]
        if value != nil {
            params.append(value!)
        }
        return fetch(method: "constant", params: params, completionHandler: completionHandler)
    }
    
    @discardableResult public func createAccount(completionHandler: ((_ result: Wallet?, _ error: Error?) -> Void)? = nil) -> Wallet? {
        return fetch(method: "createAccount", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func createRawTransaction(transaction: OutgoingTransaction, completionHandler: ((_ result: String?, _ error: Error?) -> Void)? = nil) -> String? {
        var params:[String:Any] = [
            "from": transaction.from,
            "to": transaction.to,
            "value": transaction.value,
            "fee": transaction.fee
        ]

        if transaction.fromType != nil {
            params["fromType"] = transaction.fromType
        }
        if transaction.toType != nil {
            params["toType"] = transaction.toType
        }
        if transaction.data != nil {
            params["data"] = transaction.data
        }
        
        return fetch(method: "createRawTransaction", params: [params], completionHandler: completionHandler)
    }
    
    @discardableResult public func getAccount(account: Address, completionHandler: ((_ result: Account?, _ error: Error?) -> Void)? = nil) -> Account? {
        return fetch(method: "getAccount", params: [account], completionHandler: completionHandler)
    }

    @discardableResult public func getBalance(account: Address, completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        return fetch(method: "getBalance", params: [account], completionHandler: completionHandler)
    }
    
    @discardableResult public func getBlockByHash(hash: Hash, fullTransactions: Bool = false, completionHandler: ((_ result: Block?, _ error: Error?) -> Void)? = nil) -> Block? {
        return fetch(method: "getBlockByHash", params: [hash, fullTransactions], completionHandler: completionHandler)
    }
    
    @discardableResult public func getBlockByNumber(number: Int, fullTransactions: Bool = false, completionHandler: ((_ result: Block?, _ error: Error?) -> Void)? = nil) -> Block? {
        return fetch(method: "getBlockByNumber", params: [number, fullTransactions], completionHandler: completionHandler)
    }
    
    @discardableResult public func getBlockTemplate(address: Address, extraData: String, completionHandler: ((_ result: BlockTemplate?, _ error: Error?) -> Void)? = nil) -> BlockTemplate? {
        return fetch(method: "getBlockTemplate", params: [address, extraData], completionHandler: completionHandler)
    }
    
    @discardableResult public func getBlockTransactionCountByHash(hash: Hash, completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        return fetch(method: "getBlockTransactionCountByHash", params: [hash], completionHandler: completionHandler)
    }

    @discardableResult public func getBlockTransactionCountByNumber(number: Int, completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        return fetch(method: "getBlockTransactionCountByNumber", params: [number], completionHandler: completionHandler)
    }
    
    @discardableResult public func getTransactionByBlockHashAndIndex(hash: Hash, index: Int, completionHandler: ((_ result: Transaction?, _ error: Error?) -> Void)? = nil) -> Transaction? {
        return fetch(method: "getTransactionByBlockHashAndIndex", params: [hash, index], completionHandler: completionHandler)
    }
    
    @discardableResult public func getTransactionByBlockNumberAndIndex(number: Int, index: Int, completionHandler: ((_ result: Transaction?, _ error: Error?) -> Void)? = nil) -> Transaction? {
        return fetch(method: "getTransactionByBlockNumberAndIndex", params: [number, index], completionHandler: completionHandler)
    }
    
    @discardableResult public func getTransactionByHash(hash: Hash, completionHandler: ((_ result: Transaction?, _ error: Error?) -> Void)? = nil) -> Transaction? {
        return fetch(method: "getTransactionByHash", params: [hash], completionHandler: completionHandler)
    }
    
    @discardableResult public func getTransactionReceipt(hash: Hash, completionHandler: ((_ result: TransactionReceipt?, _ error: Error?) -> Void)? = nil) -> TransactionReceipt? {
        return fetch(method: "getTransactionReceipt", params: [hash], completionHandler: completionHandler)
    }
    
    @discardableResult public func getTransactionsByAddress(address: Address, numberOfTransactions: Int = 1000, completionHandler: ((_ result: [Transaction]?, _ error: Error?) -> Void)? = nil) -> [Transaction]? {
        return fetch(method: "getTransactionsByAddress", params: [address, numberOfTransactions], completionHandler: completionHandler)
    }
    
    @discardableResult public func getWork(address: Address, extraData: String, completionHandler: ((_ result: WorkInstructions?, _ error: Error?) -> Void)? = nil) -> WorkInstructions? {
        return fetch(method: "getWork", params: [address, extraData], completionHandler: completionHandler)
    }
    
    @discardableResult public func hashrate(completionHandler: ((_ result: Float?, _ error: Error?) -> Void)? = nil) -> Float? {
        return fetch(method: "hashrate", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func log(tag: String, level: LogLevel, completionHandler: ((_ result: Bool?, _ error: Error?) -> Void)? = nil) -> Bool? {
        return fetch(method: "log", params: [tag, level.rawValue], completionHandler: completionHandler)
    }
    
    @discardableResult public func mempool(completionHandler: ((_ result: MempoolInfo?, _ error: Error?) -> Void)? = nil) -> MempoolInfo? {
        return fetch(method: "mempool", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func mempoolContent(fullTransactions: Bool = false, completionHandler: ((_ result: [Any]?, _ error: Error?) -> Void)? = nil) -> [Any]? {
        let result: [HashOrTransaction] = fetch(method: "mempoolContent", params: [fullTransactions], completionHandler: completionHandler)!
        var converted: [Any] = [Any]()
        for transaction in result {
            converted.append(transaction.value)
        }
        return converted
    }
    
    @discardableResult public func minerAddress(completionHandler: ((_ result: String?, _ error: Error?) -> Void)? = nil) -> String? {
        return fetch(method: "minerAddress", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func minerThreads(threads: Int? = nil, completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        var params: [Int] = [Int]()
        if threads != nil {
            params.append(threads!)
        }
        return fetch(method: "minerThreads", params: params, completionHandler: completionHandler)
    }
    
    @discardableResult public func minFeePerByte(fee: Int? = nil, completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        var params: [Int] = [Int]()
        if fee != nil {
            params.append(fee!)
        }
        return fetch(method: "minFeePerByte", params: params, completionHandler: completionHandler)
    }
    
    @discardableResult public func mining(completionHandler: ((_ result: Bool?, _ error: Error?) -> Void)? = nil) -> Bool? {
        return fetch(method: "mining", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func peerCount(completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        return fetch(method: "peerCount", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func peerList(completionHandler: ((_ result: [Peer]?, _ error: Error?) -> Void)? = nil) -> [Peer]? {
        return fetch(method: "peerList", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func peerState(address: String, completionHandler: ((_ result: Peer?, _ error: Error?) -> Void)? = nil) -> Peer? {
        return fetch(method: "peerState", params: [address], completionHandler: completionHandler)
    }
    
    @discardableResult public func pool(address: Any? = nil, completionHandler: ((_ result: String?, _ error: Error?) -> Void)? = nil) -> String? {
        var params: [Any] = [Any]()
        if let stringAddress = address as? String {
            params.append(stringAddress)
        } else if let stringBool = address as? Bool {
            params.append(stringBool)
        }
        return fetch(method: "pool", params: params, completionHandler: completionHandler)
    }
    
    @discardableResult public func poolConfirmedBalance(completionHandler: ((_ result: Int?, _ error: Error?) -> Void)? = nil) -> Int? {
        return fetch(method: "poolConfirmedBalance", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func poolConnectionState(completionHandler: ((_ result: PoolConnectionState?, _ error: Error?) -> Void)? = nil) -> PoolConnectionState? {
        return fetch(method: "poolConnectionState", params: [], completionHandler: completionHandler)
    }
    
    @discardableResult public func sendRawTransaction(transaction: String, completionHandler: ((_ result: Hash?, _ error: Error?) -> Void)? = nil) -> Hash? {
        return fetch(method: "sendRawTransaction", params: [transaction], completionHandler: completionHandler)
    }
    
    @discardableResult public func sendTransaction(transaction: OutgoingTransaction, completionHandler: ((_ result: Hash?, _ error: Error?) -> Void)? = nil) -> Hash? {
        var params:[String:Any] = [
            "from": transaction.from,
            "to": transaction.to,
            "value": transaction.value,
            "fee": transaction.fee
        ]

        if transaction.fromType != nil {
            params["fromType"] = transaction.fromType
        }
        if transaction.toType != nil {
            params["toType"] = transaction.toType
        }
        if transaction.data != nil {
            params["data"] = transaction.data
        }
        
        return fetch(method: "sendTransaction", params: [params], completionHandler: completionHandler)
    }
    
    @discardableResult public func submitBlock(_ block: String, completionHandler: ((_ result: String?, _ error: Error?) -> Void)? = nil) -> String? {
        return fetch(method: "submitBlock", params: [block], completionHandler: completionHandler)
    }
    
    @discardableResult public func syncing(completionHandler: ((_ result: Any?, _ error: Error?) -> Void)? = nil) -> Any? {
        let result: SyncStatusOrBool = fetch(method: "syncing", params: [], completionHandler: completionHandler)!
        return result.value
    }
    
}
