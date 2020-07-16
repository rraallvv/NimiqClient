import Foundation

// MARK: JSONRPC Models

/// Error returned in the response for the JSONRPC the server.
struct ResponseError: Decodable {
    var code: Int
    var message: String
}

/// Used to decode the JSONRPC response returned by the server.
struct Root<T:Decodable>: Decodable {
    var jsonrpc: String
    var result: T?
    var id: Int
    var error: ResponseError?
}

/// Type of a Nimiq account.
public enum AccountType: Int, Decodable {
    case basic = 0
    case vesting = 1
    case htlc = 2
}

/// Normal Nimiq account object returned by the server.
public struct Account: Decodable {
    var id: String
    var address: String
    var balance: Int
    var type: AccountType
}

/// Vesting contract object returned by the server.
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

/// Hashed Timelock Contract object returned by the server.
public struct HTLC : Decodable {
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

/// Nimiq account returned by the server. The especific type is in the associated value.
enum RawAccount : Decodable {
    case account(Account)
    case vesting(VestingContract)
    case htlc(HTLC)

    var value: Any {
         switch self {
         case .account(let value):
             return value
         case .vesting(let value):
             return value
         case .htlc(let value):
             return value
         }
    }

    private enum CodingKeys: String, CodingKey {
        case account, vestingContract, hashedTimeLockedContract
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .htlc(try container.decode(HTLC.self))
        } catch {
            do {
                self = .vesting(try container.decode(VestingContract.self))
            } catch {
                self = .account(try container.decode(Account.self))
            }
        }
    }
}

/// Consensus state returned by the server.
public enum ConsensusState: String, Decodable {
    case connecting
    case syncing
    case established
}

/// Nimiq wallet returned by the server.
public struct Wallet: Decodable {
    var id, address, publicKey: String
    var privateKey: String?
}

/// Can be both a hexadecimal representation or a human readable address.
public typealias Address = String

/// Used to pass the data to send transaccions.
public struct OutgoingTransaction {
    var from: Address
    var fromType: AccountType? = .basic
    var to: Address
    var toType: AccountType? = .basic
    var value: Int
    var fee: Int
    var data: String? = nil
}

/// Hexadecimal string containing a hash value.
public typealias Hash = String

/// Transaction returned by the server.
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

/// Block returned by the server.
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

/// Block template header returned by the server.
public struct BlockTemplateHeader : Decodable {
    var version: Int
    var prevHash: Hash
    var interlinkHash: Hash
    var accountsHash: Hash
    var nBits: Int
    var height: Int
}

/// Block template body returned by the server.
public struct BlockTemplateBody : Decodable {
    var hash: Hash
    var minerAddr: String
    var extraData: String
    var transactions: [String]
    var prunedAccounts: [String]
    var merkleHashes: [Hash]
}

/// Block template returned by the server.
public struct BlockTemplate : Decodable {
    var header: BlockTemplateHeader
    var interlink: String
    var body: BlockTemplateBody
    var target: Int
}

/// Transaction receipt returned by the server.
public struct TransactionReceipt : Decodable {
    var transactionHash: Hash
    var transactionIndex: Int
    var blockHash: Hash
    var blockNumber: Int
    var confirmations: Int
    var timestamp: Int
}

/// Work instructions receipt returned by the server.
public struct WorkInstructions : Decodable {
    var data: String
    var suffix: String
    var target: Int
    var algorithm: String
}

/// Used to set the log level in the JSONRPC server.
public enum LogLevel : String {
    case trace
    case verbose
    case debug
    case info
    case warn
    case error
    case assert
}

/// Mempool information returned by the server.
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

/// Transaction returned by the server. The especific type is in the associated value.
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

/// Peer address state returned by the server.
public enum PeerAddressState : Int, Decodable {
    case new = 1
    case established = 2
    case tried = 3
    case failed = 4
    case banned = 5
}

/// Peer connection state returned by the server.
public enum PeerConnectionState : Int, Decodable {
    case new = 1
    case connecting = 2
    case connected = 3
    case negotiating = 4
    case established = 5
    case closed = 6
}

/// Peer information returned by the server.
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

/// Commands to change the state of a peer.
public enum PeerStateCommand : String {
    case connect
    case disconnect
    case ban
    case unban
}

/// Pool connection state information returned by the server.
public enum PoolConnectionState : Int, Decodable {
    case connected = 0
    case connecting = 1
    case closed = 2
}

/// Syncing status returned by the server.
public struct SyncStatus : Decodable {
    var startingBlock: Int
    var currentBlock: Int
    var highestBlock: Int
}

/// Syncing status returned by the server. The especific type is in the associated value.
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

// MARK: -
// MARK: JSONRPC Client

/// Used in convenience initializer in the NimiqClient class.
public struct Config {
    var scheme: String
    var host: String
    var port: Int
    var user: String
    var password: String
}

/// Thrown when somthing when wrong with the JSONRPC request.
public enum Error: Swift.Error, Equatable {
    /// Couldn't parse the JSONRPC request to be sent.
    case wrongFormat(_ message: String)
    /// The server didn't recognize the method.
    case badMethodCall(_ message: String)
}

/// Nimiq JSONRPC Client
public class NimiqClient {

    /// Number in the sequence for the of the next request.
    public var id: Int = 0

    /// URL of the JSONRPC server.
    /// - Format: scheme://user:password@host:port
    private let url: String

    /// URLSession used for HTTP requests send to the JSONRPC server.
    private let session: URLSession

    /// Client initialization from a Config structure using shared URLSession.
    /// - Parameter config: Options used for the configuration.
    convenience init(config: Config) {
        self.init(scheme: config.scheme, user: config.user, password: config.password, host: config.host, port: config.port)
    }

    /// Client initialization.
    /// - Parameter scheme: Protocol squeme, `"http"` or `"https"`.
    /// - Parameter user: Authorized user.
    /// - Parameter password: Password for the authorized user.
    /// - Parameter host: Host IP address.
    /// - Parameter port: Host port.
    /// - Parameter session: Used to make all requests. If ommited the shared URLSession is used.
    init(scheme: String, user: String, password: String, host: String, port: Int, session: URLSession? = nil){
        self.url = "\(scheme)://\(user):\(password)@\(host):\(port)"
        if session != nil {
            self.session = session!
        } else {
            self.session = URLSession.shared
        }
    }

    /// Used in all JSONRPC requests to fetch the data.
    /// - Parameter method: JSONRPC method.
    /// - Parameter params: Parameters used by the request.
    /// - Returns: If succesfull, returns the model reperestation of the result, `nil` otherwise.
    private func fetch<T:Decodable>(method: String, params: [Any]) throws -> T? {
        var responseObject: Root<T>? = nil
        var clientError: Error? = nil

        // make JSON object to send to the server
        let callObject:[String:Any] = [
            "jsonrpc": "2.0",
            "method": method,
            "params": params,
            "id": id
        ]

        // prepare the request
        let data = try JSONSerialization.data(withJSONObject: callObject, options: [])
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        // TODO: find a better way to fix the error when the server terminates the connection prematurely
        request.addValue("close", forHTTPHeaderField: "Connection")

        let semaphore = DispatchSemaphore(value: 0)

        // send the request
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            // serialize the data into an object
            do {
                responseObject = try JSONDecoder().decode(Root<T>.self, from: data! )

            } catch {
                clientError = Error.wrongFormat(error.localizedDescription)
            }

            // signal that the request was completed
            semaphore.signal()
        })
        task.resume()

        // wait for the response
        semaphore.wait()

        // throw if there are any errors
        if clientError != nil {
            throw clientError!
        }

        if let error = responseObject?.error {
            throw Error.badMethodCall("\(error.message) (Code: \(error.code)")
        }

        // increase the JSONRPC client request id for the next request
        self.id = self.id + 1

        return responseObject?.result
    }

    /// Returns a list of addresses owned by client.
    /// - Returns: Array of Accounts owned by the client.
    public func accounts() throws -> [Any]? {
        let result: [RawAccount] = try fetch(method: "accounts", params: [])!
        var converted: [Any] = [Any]()
        for rawAccount in result {
            converted.append(rawAccount.value)
        }
        return converted
    }

    /// Returns the height of most recent block.
    /// - Returns: The current block height the client is on.
    public func blockNumber() throws -> Int? {
        return try fetch(method: "blockNumber", params: [])
    }

    /// Returns information on the current consensus state.
    /// - Returns: Consensus state. `established` is the value for a good state, other values indicate bad.
    public func consensus() throws -> ConsensusState? {
        return try fetch(method: "consensus", params: [])
    }

    /// Returns or overrides a constant value.
    /// When no parameter is given, it returns the value of the constant. When giving a value as parameter,
    /// it sets the constant to the given value. To reset the constant use `resetConstant()` instead.
    /// - Parameter string: The class and name of the constant (format should be `Class.CONSTANT`).
    /// - Parameter value: The new value of the constant.
    /// - Returns: The value of the constant.
    public func constant(_ constant: String, value: Int? = nil) throws -> Int? {
        var params:[Any] = [constant]
        if value != nil {
            params.append(value!)
        }
        return try fetch(method: "constant", params: params)
    }

    /// Creates a new account and stores its private key in the client store.
    /// - Returns: Information on the wallet that was created using the command.
    public func createAccount() throws -> Wallet? {
        return try fetch(method: "createAccount", params: [])
    }

    /// Creates and signs a transaction without sending it. The transaction can then be send via `sendRawTransaction()` without accidentally replaying it.
    /// - Parameter transaction: The transaction object.
    /// - Returns: Hex-encoded transaction.
    public func createRawTransaction(_ transaction: OutgoingTransaction) throws -> String? {
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

    /// Returns details for the account of given address.
    /// - Parameter address: Address to get account details.
    /// - Returns: Details about the account. Returns the default empty basic account for non-existing accounts.
    public func getAccount(address: Address) throws -> Any? {
        let result: RawAccount = try fetch(method: "getAccount", params: [address])!
        return result.value
    }

    /// Returns the balance of the account of given address.
    /// - Parameter address: Address to check for balance.
    /// - Returns: The current balance at the specified address (in smalest unit).
    public func getBalance(address: Address) throws -> Int? {
        return try fetch(method: "getBalance", params: [address])
    }

    /// Returns information about a block by hash.
    /// - Parameter hash: Hash of the block to gather information on.
    /// - Parameter fullTransactions: If `true` it returns the full transaction objects, if `false` only the hashes of the transactions.
    /// - Returns: A block object or `nil` when no block was found.
    public func getBlockByHash(_ hash: Hash, fullTransactions: Bool = false) throws -> Block? {
        return try fetch(method: "getBlockByHash", params: [hash, fullTransactions])
    }

    /// Returns information about a block by block number.
    /// - Parameter height: The height of the block to gather information on.
    /// - Parameter fullTransactions: If `true` it returns the full transaction objects, if `false` only the hashes of the transactions.
    /// - Returns: A block object or `nil` when no block was found.
    public func getBlockByNumber(height: Int, fullTransactions: Bool = false) throws -> Block? {
        return try fetch(method: "getBlockByNumber", params: [height, fullTransactions])
    }

    /// Returns a template to build the next block for mining. This will consider pool instructions when connected to a pool.
    /// If `address` and `extraData` are provided the values are overriden.
    /// - Parameter address: The address to use as a miner for this block. This overrides the address provided during startup or from the pool.
    /// - Parameter extraData: Hex-encoded value for the extra data field. This overrides the extra data provided during startup or from the pool.
    /// - Returns: A block template object.
    public func getBlockTemplate(address: Address? = nil, extraData: String = "") throws -> BlockTemplate? {
        var params: [Any] = [Any]()
        if address != nil {
            params.append(address!)
            params.append(extraData)
        }
        return try fetch(method: "getBlockTemplate", params: params)

    }

    /// Returns the number of transactions in a block from a block matching the given block hash.
    /// - Parameter hash: Hash of the block.
    /// - Returns: Number of transactions in the block found, or `nil`, when no block was found.
    public func getBlockTransactionCountByHash(_ hash: Hash) throws -> Int? {
        return try fetch(method: "getBlockTransactionCountByHash", params: [hash])
    }

    /// Returns the number of transactions in a block matching the given block number.
    /// - Parameter height: Height of the block.
    /// - Returns: Number of transactions in the block found, or `nil`, when no block was found.
    public func getBlockTransactionCountByNumber(height: Int) throws -> Int? {
        return try fetch(method: "getBlockTransactionCountByNumber", params: [height])
    }

    /// Returns information about a transaction by block hash and transaction index position.
    /// - Parameter hash: Hash of the block containing the transaction.
    /// - Parameter index: Index of the transaction in the block.
    /// - Returns: A transaction object or `nil` when no transaction was found.
    public func getTransactionByBlockHashAndIndex(hash: Hash, index: Int) throws -> Transaction? {
        return try fetch(method: "getTransactionByBlockHashAndIndex", params: [hash, index])
    }

    /// Returns information about a transaction by block number and transaction index position.
    /// - Parameter height: Height of the block containing the transaction.
    /// - Parameter index: Index of the transaction in the block.
    /// - Returns: A transaction object or `nil` when no transaction was found.
    public func getTransactionByBlockNumberAndIndex(height: Int, index: Int) throws -> Transaction? {
        return try fetch(method: "getTransactionByBlockNumberAndIndex", params: [height, index])
    }

    /// Returns the information about a transaction requested by transaction hash.
    /// - Parameter hash: Hash of a transaction
    /// - Returns: A transaction object or `nil` when no transaction was found.
    public func getTransactionByHash(_ hash: Hash) throws -> Transaction? {
        return try fetch(method: "getTransactionByHash", params: [hash])
    }

    /// Returns the receipt of a transaction by transaction hash.
    /// - Parameter hash: Hash of a transaction.
    /// - Returns: A transaction receipt object, or `nil` when no receipt was found:
    public func getTransactionReceipt(hash: Hash) throws -> TransactionReceipt? {
        return try fetch(method: "getTransactionReceipt", params: [hash])
    }

    /// Returns the latest transactions successfully performed by or for an address.
    /// Note that this information might change when blocks are rewinded on the local state due to forks.
    /// - Parameter address: Address of which transactions should be gathered.
    /// - Parameter numberOfTransactions: Number of transactions that shall be returned.
    /// - Returns: Array of transactions linked to the requested address.
    public func getTransactionsByAddress(_ address: Address, numberOfTransactions: Int = 1000) throws -> [Transaction]? {
        return try fetch(method: "getTransactionsByAddress", params: [address, numberOfTransactions])
    }

    /// Returns instructions to mine the next block. This will consider pool instructions when connected to a pool.
    /// - Parameter address: The address to use as a miner for this block. This overrides the address provided during startup or from the pool.
    /// - Parameter extraData: Hex-encoded value for the extra data field. This overrides the extra data provided during startup or from the pool.
    /// - Returns: Mining work instructions.
    public func getWork(address: Address? = nil, extraData: String = "") throws -> WorkInstructions? {
        var params: [Any] = [Any]()
        if address != nil {
            params.append(address!)
            params.append(extraData)
        }
        return try fetch(method: "getWork", params: params)
    }

    /// Returns the number of hashes per second that the node is mining with.
    /// - Returns: Number of hashes per second.
    public func hashrate() throws -> Float? {
        return try fetch(method: "hashrate", params: [])
    }

    /// Sets the log level of the node.
    /// - Parameter tag: Tag: If `"*"` the log level is set globally, otherwise the log level is applied only on this tag.
    /// - Parameter level: Minimum log level to display.
    /// - Returns: `true` if the log level was changed, `false` otherwise.
    public func log(tag: String, level: LogLevel) throws -> Bool? {
        return try fetch(method: "log", params: [tag, level.rawValue])
    }

    /// Returns information on the current mempool situation. This will provide an overview of the number of transactions sorted into buckets based on their fee per byte (in smallest unit).
    /// - Returns: Mempool information.
    public func mempool() throws -> MempoolInfo? {
        return try fetch(method: "mempool", params: [])
    }

    /// Returns transactions that are currently in the mempool.
    /// - Parameter fullTransactions: If `true` includes full transactions, if `false` includes only transaction hashes.
    /// - Returns: Array of transactions (either represented by the transaction hash or a transaction object).
    public func mempoolContent(fullTransactions: Bool = false) throws -> [Any]? {
        let result: [HashOrTransaction] = try fetch(method: "mempoolContent", params: [fullTransactions])!
        var converted: [Any] = [Any]()
        for transaction in result {
            converted.append(transaction.value)
        }
        return converted
    }

    /// Returns the miner address.
    /// - Returns: The miner address configured on the node.
    public func minerAddress() throws -> String? {
        return try fetch(method: "minerAddress", params: [])
    }

    /// Returns or sets the number of CPU threads for the miner.
    /// When no parameter is given, it returns the current number of miner threads.
    /// When a value is given as parameter, it sets the number of miner threads to that value.
    /// - Parameter threads: The number of threads to allocate for mining.
    /// - Returns: The number of threads allocated for mining.
    public func minerThreads(_ threads: Int? = nil) throws -> Int? {
        var params: [Int] = [Int]()
        if threads != nil {
            params.append(threads!)
        }
        return try fetch(method: "minerThreads", params: params)
    }

    /// Returns or sets the minimum fee per byte.
    /// When no parameter is given, it returns the current minimum fee per byte.
    /// When a value is given as parameter, it sets the minimum fee per byte to that value.
    /// - Parameter fee: The new minimum fee per byte.
    /// - Returns: The new minimum fee per byte.
    public func minFeePerByte(fee: Int? = nil) throws -> Int? {
        var params: [Int] = [Int]()
        if fee != nil {
            params.append(fee!)
        }
        return try fetch(method: "minFeePerByte", params: params)
    }

    /// Returns true if client is actively mining new blocks.
    /// When no parameter is given, it returns the current state.
    /// When a value is given as parameter, it sets the current state to that value.
    /// - Parameter state: The state to be set.
    /// - Returns: `true` if the client is mining, otherwise `false`.
    public func mining(state: Bool? = nil) throws -> Bool? {
        var params: [Bool] = [Bool]()
        if state != nil {
            params.append(state!)
        }
        return try fetch(method: "mining", params: params)
    }

    /// Returns number of peers currently connected to the client.
    /// - Returns: Number of connected peers.
    public func peerCount() throws -> Int? {
        return try fetch(method: "peerCount", params: [])
    }

    /// Returns list of peers known to the client.
    /// - Returns: The list of peers.
    public func peerList() throws -> [Peer]? {
        return try fetch(method: "peerList", params: [])
    }

    /// Returns the state of the peer.
    /// When no command is given, it returns peer state.
    /// When a value is given for command, it sets the peer state to that value.
    /// - Parameter address: The address of the peer.
    /// - Parameter command: The command to send.
    /// - Returns: The current state of the peer.
    public func peerState(address: String, command: PeerStateCommand? = nil) throws -> Peer? {
        var params: [Any] = [Any]()
        params.append(address)
        if let commandString = command?.rawValue  {
            params.append(commandString)
        }
        return try fetch(method: "peerState", params: params)
    }

    /// Returns or sets the mining pool.
    /// When no parameter is given, it returns the current mining pool.
    /// When a value is given as parameter, it sets the mining pool to that value.
    /// - Parameter address: The mining pool connection string (`url:port`) or boolean to enable/disable pool mining.
    /// - Returns: The mining pool connection string, or `nil` if not enabled.
    public func pool(address: Any? = nil) throws -> String? {
        var params: [Any] = [Any]()
        if let addressString = address as? String {
            params.append(addressString)
        } else if let addressBool = address as? Bool {
            params.append(addressBool)
        }
        return try fetch(method: "pool", params: params)
    }

    /// Returns the confirmed mining pool balance.
    /// - Returns: The confirmed mining pool balance (in smallest unit).
    public func poolConfirmedBalance() throws -> Int? {
        return try fetch(method: "poolConfirmedBalance", params: [])
    }

    /// Returns the connection state to mining pool.
    /// - Returns: The mining pool connection state.
    public func poolConnectionState() throws -> PoolConnectionState? {
        return try fetch(method: "poolConnectionState", params: [])
    }

    /// Sends a signed message call transaction or a contract creation, if the data field contains code.
    /// - Parameter transaction: The hex encoded signed transaction
    /// - Returns: The Hex-encoded transaction hash.
    public func sendRawTransaction(_ transaction: String) throws -> Hash? {
        return try fetch(method: "sendRawTransaction", params: [transaction])
    }

    /// Creates new message call transaction or a contract creation, if the data field contains code.
    /// - Parameter transaction: The hex encoded signed transaction
    /// - Returns: The Hex-encoded transaction hash.
    public func sendTransaction(_ transaction: OutgoingTransaction) throws -> Hash? {
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

    /// Submits a block to the node. When the block is valid, the node will forward it to other nodes in the network.
    /// - Parameter block: Hex-encoded full block (including header, interlink and body). When submitting work from getWork, remember to include the suffix.
    /// - Returns: Always `nil`.
    @discardableResult public func submitBlock(_ block: String) throws -> String? {
        return try fetch(method: "submitBlock", params: [block])
    }

    /// Returns an object with data about the sync status or `false`.
    /// - Returns: An object with sync status data or `false`, when not syncing.
    public func syncing() throws -> Any? {
        let result: SyncStatusOrBool = try fetch(method: "syncing", params: [])!
        return result.value
    }

    /// Deserializes hex-encoded transaction and returns a transaction object.
    /// - Parameter transaction: The hex encoded signed transaction.
    /// - Returns: The transaction object
    public func getRawTransactionInfo(transaction: String) throws -> Transaction? {
        return try fetch(method: "getRawTransactionInfo", params: [transaction])
    }

    /// Resets the constant to default value.
    /// - Parameter constant: Name of the constant.
    /// - Returns: The new value of the constant.
    public func resetConstant(_ constant: String) throws -> Int? {
        return try fetch(method: "constant", params: [constant, "reset"])
    }
}
