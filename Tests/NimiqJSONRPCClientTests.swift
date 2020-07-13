import XCTest

class URLProtocolStub: URLProtocol {
    // test data
    static var testData: Data?

    // handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // send back the request as is
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // load test data
        self.client?.urlProtocol(self, didLoad: URLProtocolStub.testData!)

        // request has finished
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // doesn't need to do anything
    override func stopLoading() { }
}

class NimiqJSONRPCClientTests: XCTestCase {
    
    var client: NimiqJSONRPCClient!
    
    override func setUp() {
        super.setUp()

        // set up a configuration for the stub
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]

        // create URLSession from configuration
        let session = URLSession(configuration: config)

        // init our JSON RPC client with that
        client = NimiqJSONRPCClient(scheme: "http", user: "user", password: "password", host: "127.0.0.1", port: 8648, session: session)
        
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test_accounts() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": [
                {
                  "id": "f925107376081be421f52d64bec775cc1fc20829",
                  "address": "NQ33 Y4JH 0UTN 10DX 88FM 5MJB VHTM RGFU 4219",
                  "balance": 0,
                  "type": 0
                },
                {
                  "id": "ebcbf0de7dae6a42d1c12967db9b2287bf2f7f0f",
                  "address": "NQ09 VF5Y 1PKV MRM4 5LE1 55KV P6R2 GXYJ XYQF",
                  "balance": 52500000000000,
                  "type": 1,
                  "owner": "fd34ab7265a0e48c454ccbf4c9c61dfdf68f9a22",
                  "ownerAddress": "NQ62 YLSA NUK5 L3J8 QHAC RFSC KHGV YPT8 Y6H2",
                  "vestingStart": 1,
                  "vestingStepBlocks": 259200,
                  "vestingStepAmount": 2625000000000,
                  "vestingTotalAmount": 52500000000000
                },
                {
                  "id": "4974636bd6d34d52b7d4a2ee4425dc2be72a2b4e",
                  "address": "NQ46 NTNU QX94 MVD0 BBT0 GXAR QUHK VGNF 39ET",
                  "balance": 1000000000,
                  "type": 2,
                  "sender": "d62d519b3478c63bdd729cf2ccb863178060c64a",
                  "senderAddress": "NQ53 SQNM 36RL F333 PPBJ KKRC RE33 2X06 1HJA",
                  "recipient": "f5ad55071730d3b9f05989481eefbda7324a44f8",
                  "recipientAddress": "NQ41 XNNM A1QP 639T KU2R H541 VTVV LUR4 LH7Q",
                  "hashRoot": "df331b3c8f8a889703092ea05503779058b7f44e71bc57176378adde424ce922",
                  "hashAlgorithm": 1,
                  "hashCount": 1,
                  "timeout": 1105605,
                  "totalAmount": 1000000000
                }
              ],
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.accounts()!
        
        let account = actualData[0] as! Account
        
        XCTAssertEqual(account.id, "f925107376081be421f52d64bec775cc1fc20829")
        XCTAssertEqual(account.address, "NQ33 Y4JH 0UTN 10DX 88FM 5MJB VHTM RGFU 4219")
        XCTAssertEqual(account.balance, 0)
        XCTAssertEqual(account.type, AccountType.basic)

        let vesting = actualData[1] as! VestingContract
        
        XCTAssertEqual(vesting.id, "ebcbf0de7dae6a42d1c12967db9b2287bf2f7f0f")
        XCTAssertEqual(vesting.address, "NQ09 VF5Y 1PKV MRM4 5LE1 55KV P6R2 GXYJ XYQF")
        XCTAssertEqual(vesting.balance, 52500000000000)
        XCTAssertEqual(vesting.type, AccountType.vesting)
        XCTAssertEqual(vesting.owner, "fd34ab7265a0e48c454ccbf4c9c61dfdf68f9a22")
        XCTAssertEqual(vesting.ownerAddress, "NQ62 YLSA NUK5 L3J8 QHAC RFSC KHGV YPT8 Y6H2")
        XCTAssertEqual(vesting.vestingStart, 1)
        XCTAssertEqual(vesting.vestingStepBlocks, 259200)
        XCTAssertEqual(vesting.vestingStepAmount, 2625000000000)
        XCTAssertEqual(vesting.vestingTotalAmount, 52500000000000)

        let htlc = actualData[2] as! HashedTimeLockedContract
        
        XCTAssertEqual(htlc.id, "4974636bd6d34d52b7d4a2ee4425dc2be72a2b4e")
        XCTAssertEqual(htlc.address, "NQ46 NTNU QX94 MVD0 BBT0 GXAR QUHK VGNF 39ET")
        XCTAssertEqual(htlc.balance, 1000000000)
        XCTAssertEqual(htlc.type, AccountType.htlc)
        XCTAssertEqual(htlc.sender, "d62d519b3478c63bdd729cf2ccb863178060c64a")
        XCTAssertEqual(htlc.senderAddress, "NQ53 SQNM 36RL F333 PPBJ KKRC RE33 2X06 1HJA")
        XCTAssertEqual(htlc.recipient, "f5ad55071730d3b9f05989481eefbda7324a44f8")
        XCTAssertEqual(htlc.recipientAddress, "NQ41 XNNM A1QP 639T KU2R H541 VTVV LUR4 LH7Q")
        XCTAssertEqual(htlc.hashRoot, "df331b3c8f8a889703092ea05503779058b7f44e71bc57176378adde424ce922")
        XCTAssertEqual(htlc.hashAlgorithm, 1)
        XCTAssertEqual(htlc.hashCount, 1)
        XCTAssertEqual(htlc.timeout, 1105605)
        XCTAssertEqual(htlc.totalAmount, 1000000000)        
    }
    
    func test_blockNumber() {
        let expectedData = """
            {
              "id":83,
              "jsonrpc": "2.0",
              "result": 1207
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.blockNumber()!
        
        XCTAssertEqual(actualData, 1207)
    }
    
    func test_consensus() {
        let expectedData = """
            {
              "id":83,
              "jsonrpc": "2.0",
              "result": "established"
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.consensus()!
        
        XCTAssertEqual(actualData, ConsensusState.established)
    }
    
    func test_constant() {
        let expectedData = """
            {
              "id":83,
              "jsonrpc": "2.0",
              "result": 10
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.constant(constant: "BaseConsensus.MAX_ATTEMPTS_TO_FETCH", value: 10)
        
        XCTAssertEqual(actualData, 10)
    }
    
    func test_createAccount() {
        let expectedData = """
            {
              "id":83,
              "jsonrpc": "2.0",
              "result": {
                "id": "c2260ff07885654f8111e71f72967d397ec8c3c0",
                "address": "NQ30 Q8K0 YU3Q GMJL Y08H UUFP 55KV 75YC HGX0",
                "publicKey": "b7de7c978a6616d887fd16c62193402ba96c99005034833fbec0c0fe766fdf8b"
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.createAccount()!
        
        XCTAssertEqual(actualData.id, "c2260ff07885654f8111e71f72967d397ec8c3c0")
        XCTAssertEqual(actualData.address, "NQ30 Q8K0 YU3Q GMJL Y08H UUFP 55KV 75YC HGX0")
        XCTAssertEqual(actualData.publicKey, "b7de7c978a6616d887fd16c62193402ba96c99005034833fbec0c0fe766fdf8b")
    }
    
    func test_createRawTransaction() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": "010000...abcdef"
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.createRawTransaction(transaction: OutgoingTransaction(
            from: "NQ94 VESA PKTA 9YQ0 XKGC HVH0 Q9DF VSFU STSP",
            to: "NQ16 61ET MB3M 2JG6 TBLK BR0D B6EA X6XQ L91U",
            value: 100000,
            fee: 0
        ))!
        
        XCTAssertEqual(actualData, "010000...abcdef")
    }
    
    func test_getAccount() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": {
                "id": "ad25610feb43d75307763d3f010822a757027429",
                "address": "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19",
                "balance": 1200000,
                "type": 0
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.getAccount(account: "ad25610feb43d75307763d3f010822a757027429") as! Account
        
        XCTAssertEqual(actualData.id, "ad25610feb43d75307763d3f010822a757027429")
        XCTAssertEqual(actualData.address, "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19")
        XCTAssertEqual(actualData.balance, 1200000)
        XCTAssertEqual(actualData.type, AccountType.basic)
    }
    
    func test_getBalance() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": 1200000
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.getBalance(account: "ad25610feb43d75307763d3f010822a757027429")!
        
        XCTAssertEqual(actualData, 1200000)
    }

    func test_getBlockByHash() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": {
                "number": 20,
                "hash": "14c91f6d6f3a0b62271e546bb09461231ab7e4d1ddc2c3e1b93de52d48a1da87",
                "pow": "000008df8cfee0a3b1dde716aec59df53fd3d984ae2220565b90d0aae5fa3153",
                "parentHash": "1a7306ecd1d1dff4d921c985e5cbc084275bfa6a8bed68549c3275d1c38614f6",
                "nonce": 67426,
                "bodyHash": "9c29ffd4da6ce51e1618cd0eb70731ff8e63c14ec2092424ac6e25f2983dd42f",
                "accountsHash": "27aa836a72b9eea1b5d890a0e20a9dfa5ada50d3a00e9788836144c0e85627d8",
                "difficulty": "1.1886029345",
                "timestamp": 1523727013,
                "confirmations": 0,
                "miner": "0000000000000000000000000000000000000000",
                "minerAddress": "NQ07 0000 0000 0000 0000 0000 0000 0000 0000",
                "extraData": "4d696e65642077697468206c6f76652062792053696d6f6e",
                "size": 230,
                "transactions": []
              },
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.getBlockByHash(hash: "14c91f6d6f3a0b62271e546bb09461231ab7e4d1ddc2c3e1b93de52d48a1da87", fullTransactions: false)!
        
        XCTAssertEqual(actualData.number, 20)
        XCTAssertEqual(actualData.hash, "14c91f6d6f3a0b62271e546bb09461231ab7e4d1ddc2c3e1b93de52d48a1da87")
        XCTAssertEqual(actualData.pow, "000008df8cfee0a3b1dde716aec59df53fd3d984ae2220565b90d0aae5fa3153")
        XCTAssertEqual(actualData.parentHash, "1a7306ecd1d1dff4d921c985e5cbc084275bfa6a8bed68549c3275d1c38614f6")
        XCTAssertEqual(actualData.nonce, 67426)
        XCTAssertEqual(actualData.bodyHash, "9c29ffd4da6ce51e1618cd0eb70731ff8e63c14ec2092424ac6e25f2983dd42f")
        XCTAssertEqual(actualData.accountsHash, "27aa836a72b9eea1b5d890a0e20a9dfa5ada50d3a00e9788836144c0e85627d8")
        XCTAssertEqual(actualData.difficulty, "1.1886029345")
        XCTAssertEqual(actualData.timestamp, 1523727013)
        XCTAssertEqual(actualData.confirmations, 0)
        XCTAssertEqual(actualData.miner, "0000000000000000000000000000000000000000")
        XCTAssertEqual(actualData.minerAddress, "NQ07 0000 0000 0000 0000 0000 0000 0000 0000")
        XCTAssertEqual(actualData.extraData, "4d696e65642077697468206c6f76652062792053696d6f6e")
        XCTAssertEqual(actualData.size, 230)
        XCTAssertEqual(actualData.transactions.count, 0)
    }
    
    func test_getBlockByNumber() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": {
                "number": 20,
                "hash": "14c91f6d6f3a0b62271e546bb09461231ab7e4d1ddc2c3e1b93de52d48a1da87",
                "pow": "000008df8cfee0a3b1dde716aec59df53fd3d984ae2220565b90d0aae5fa3153",
                "parentHash": "1a7306ecd1d1dff4d921c985e5cbc084275bfa6a8bed68549c3275d1c38614f6",
                "nonce": 67426,
                "bodyHash": "9c29ffd4da6ce51e1618cd0eb70731ff8e63c14ec2092424ac6e25f2983dd42f",
                "accountsHash": "27aa836a72b9eea1b5d890a0e20a9dfa5ada50d3a00e9788836144c0e85627d8",
                "difficulty": "1.1886029345",
                "timestamp": 1523727013,
                "confirmations": 0,
                "miner": "0000000000000000000000000000000000000000",
                "minerAddress": "NQ07 0000 0000 0000 0000 0000 0000 0000 0000",
                "extraData": "4d696e65642077697468206c6f76652062792053696d6f6e",
                "size": 230,
                "transactions": []
              },
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        let actualData = client.getBlockByNumber(number: 20, fullTransactions: false)!
        
        XCTAssertEqual(actualData.number, 20)
        XCTAssertEqual(actualData.hash, "14c91f6d6f3a0b62271e546bb09461231ab7e4d1ddc2c3e1b93de52d48a1da87")
        XCTAssertEqual(actualData.pow, "000008df8cfee0a3b1dde716aec59df53fd3d984ae2220565b90d0aae5fa3153")
        XCTAssertEqual(actualData.parentHash, "1a7306ecd1d1dff4d921c985e5cbc084275bfa6a8bed68549c3275d1c38614f6")
        XCTAssertEqual(actualData.nonce, 67426)
        XCTAssertEqual(actualData.bodyHash, "9c29ffd4da6ce51e1618cd0eb70731ff8e63c14ec2092424ac6e25f2983dd42f")
        XCTAssertEqual(actualData.accountsHash, "27aa836a72b9eea1b5d890a0e20a9dfa5ada50d3a00e9788836144c0e85627d8")
        XCTAssertEqual(actualData.difficulty, "1.1886029345")
        XCTAssertEqual(actualData.timestamp, 1523727013)
        XCTAssertEqual(actualData.confirmations, 0)
        XCTAssertEqual(actualData.miner, "0000000000000000000000000000000000000000")
        XCTAssertEqual(actualData.minerAddress, "NQ07 0000 0000 0000 0000 0000 0000 0000 0000")
        XCTAssertEqual(actualData.extraData, "4d696e65642077697468206c6f76652062792053696d6f6e")
        XCTAssertEqual(actualData.size, 230)
        XCTAssertEqual(actualData.transactions.count, 0)
    }
    
    func test_getBlockTemplate() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": {
                "header": {
                  "version": 1,
                  "prevHash": "b6d0644d171957dfc5e85ec36fcb4772a7783c6c47da23d0b7fe9ceb1a6b85f1",
                  "interlinkHash": "960b72c50828837782b92698555e23492e4f75018a2ba5dffea0b89df436e3b0",
                  "accountsHash": "78f442b1962bf9dd07e1b25bf4c42c59e3e40eec7fedf6853c579b6cc56330c1",
                  "nBits": 503371226,
                  "height": 901883
                },
                "interlink": "11ead9805a7d47ddf5152a7d06a14ea291831c3fc7af20b88240c5ae839683021bcee3e26b8b4167517c162fa113c09606b44d24f8020804a0f756db085546ff585adfdedad9085d36527a8485b497728446c35b9b6c3db263c07dd0a1f487b1639aa37ff60ba3cf6ed8ab5146fee50a23ebd84ea37dca8c49b31e57d05c9e6c57f09a3b282b71ec2be66c1bc8268b5326bb222b11a0d0a4acd2a93c9e8a8713fe4383e9d5df3b1bf008c535281086b2bcc20e494393aea1475a5c3f13673de2cf7314d2",
                "target": 503371226,
                "body": {
                  "hash": "17e250f1977ae85bdbe09468efef83587885419ee1074ddae54d3fb5a96e1f54",
                  "minerAddr": "b7cc7f01e0e6f0e07dd9249dc598f4e5ee8801f5",
                  "extraData": "",
                  "transactions": [
                    "009207144f80a4a479b6954c342ef61747c018d368b4bb86dcb70bfc19381e0c9323c5b9092959ee29b05394e184685e3ff7d3c2a60000000029f007a6000000000000008a000dc2fa0144eccc3af5be34553193aacd543b39b21a79d32c975a9e3f958a9516ff92f134f15ae5a70cadcfcf89d3ced84dd9569d04e40d6d138e9e504ed8e70f31a3d407"
                  ],
                  "merkleHashes": [
                      "6039a78b6be96bd0b539c6b2bf52fe6e5970571e0ee3afba798f701eee561ea2"
                  ],
                  "prunedAccounts": []
                }
              },
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getBlockTemplate(address: "NQ46 NTNU QX94 MVD0 BBT0 GXAR QUHK VGNF 39ET", extraData: "")!

        XCTAssertEqual(actualData.interlink, "11ead9805a7d47ddf5152a7d06a14ea291831c3fc7af20b88240c5ae839683021bcee3e26b8b4167517c162fa113c09606b44d24f8020804a0f756db085546ff585adfdedad9085d36527a8485b497728446c35b9b6c3db263c07dd0a1f487b1639aa37ff60ba3cf6ed8ab5146fee50a23ebd84ea37dca8c49b31e57d05c9e6c57f09a3b282b71ec2be66c1bc8268b5326bb222b11a0d0a4acd2a93c9e8a8713fe4383e9d5df3b1bf008c535281086b2bcc20e494393aea1475a5c3f13673de2cf7314d2")
        XCTAssertEqual(actualData.target, 503371226)

        let header = actualData.header
            
        XCTAssertEqual(header.version, 1)
        XCTAssertEqual(header.prevHash, "b6d0644d171957dfc5e85ec36fcb4772a7783c6c47da23d0b7fe9ceb1a6b85f1")
        XCTAssertEqual(header.interlinkHash, "960b72c50828837782b92698555e23492e4f75018a2ba5dffea0b89df436e3b0")
        XCTAssertEqual(header.accountsHash, "78f442b1962bf9dd07e1b25bf4c42c59e3e40eec7fedf6853c579b6cc56330c1")
        XCTAssertEqual(header.nBits, 503371226)
        XCTAssertEqual(header.height, 901883)
        
        let body = actualData.body
        
        XCTAssertEqual(body.hash, "17e250f1977ae85bdbe09468efef83587885419ee1074ddae54d3fb5a96e1f54")
        XCTAssertEqual(body.minerAddr, "b7cc7f01e0e6f0e07dd9249dc598f4e5ee8801f5")
        XCTAssertEqual(body.extraData, "")
        XCTAssertEqual(body.transactions[0], "009207144f80a4a479b6954c342ef61747c018d368b4bb86dcb70bfc19381e0c9323c5b9092959ee29b05394e184685e3ff7d3c2a60000000029f007a6000000000000008a000dc2fa0144eccc3af5be34553193aacd543b39b21a79d32c975a9e3f958a9516ff92f134f15ae5a70cadcfcf89d3ced84dd9569d04e40d6d138e9e504ed8e70f31a3d407")
        XCTAssertEqual(body.merkleHashes[0], "6039a78b6be96bd0b539c6b2bf52fe6e5970571e0ee3afba798f701eee561ea2")
        XCTAssertEqual(body.prunedAccounts.count, 0)
    }
    
    func test_getBlockTransactionCountByHash() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": 46
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getBlockTransactionCountByHash(hash: "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f")!

        XCTAssertEqual(actualData, 46)
    }
    
    func test_getBlockTransactionCountByNumber() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": 46
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getBlockTransactionCountByNumber(number: 76415)!

        XCTAssertEqual(actualData, 46)
    }
    
    func test_getTransactionByBlockHashAndIndex() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": {
                "hash": "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554",
                "blockHash": "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f",
                "blockNumber": 76415,
                "timestamp": 1528297445,
                "confirmations": 151281,
                "transactionIndex": 20,
                "from": "ad25610feb43d75307763d3f010822a757027429",
                "fromAddress": "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19",
                "to": "824aa01033c89595479bab9d8deb3fc3a3e65e2d",
                "toAddress": "NQ44 G95A 041K R2AR AHUT MEEQ TSRY QEHX CPHD",
                "value": 418585560,
                "fee": 138,
                "data": null,
                "flags": 0
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getTransactionByBlockHashAndIndex(hash: "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f", index: 20)!

        XCTAssertEqual(actualData.hash, "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")
        XCTAssertEqual(actualData.blockHash, "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f")
        XCTAssertEqual(actualData.blockNumber, 76415)
        XCTAssertEqual(actualData.timestamp, 1528297445)
        XCTAssertEqual(actualData.confirmations, 151281)
        XCTAssertEqual(actualData.transactionIndex, 20)
        XCTAssertEqual(actualData.from, "ad25610feb43d75307763d3f010822a757027429")
        XCTAssertEqual(actualData.fromAddress, "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19")
        XCTAssertEqual(actualData.to, "824aa01033c89595479bab9d8deb3fc3a3e65e2d")
        XCTAssertEqual(actualData.toAddress, "NQ44 G95A 041K R2AR AHUT MEEQ TSRY QEHX CPHD")
        XCTAssertEqual(actualData.value, 418585560)
        XCTAssertEqual(actualData.fee, 138)
        XCTAssertEqual(actualData.data, nil)
        XCTAssertEqual(actualData.flags, 0)
    }
    
    func test_getTransactionByBlockNumberAndIndex() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": {
                "hash": "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554",
                "blockHash": "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f",
                "blockNumber": 76415,
                "timestamp": 1528297445,
                "confirmations": 151281,
                "transactionIndex": 20,
                "from": "ad25610feb43d75307763d3f010822a757027429",
                "fromAddress": "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19",
                "to": "824aa01033c89595479bab9d8deb3fc3a3e65e2d",
                "toAddress": "NQ44 G95A 041K R2AR AHUT MEEQ TSRY QEHX CPHD",
                "value": 418585560,
                "fee": 138,
                "data": null,
                "flags": 0
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getTransactionByBlockNumberAndIndex(number: 76415, index: 20)!

        XCTAssertEqual(actualData.hash, "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")
        XCTAssertEqual(actualData.blockHash, "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f")
        XCTAssertEqual(actualData.blockNumber, 76415)
        XCTAssertEqual(actualData.timestamp, 1528297445)
        XCTAssertEqual(actualData.confirmations, 151281)
        XCTAssertEqual(actualData.transactionIndex, 20)
        XCTAssertEqual(actualData.from, "ad25610feb43d75307763d3f010822a757027429")
        XCTAssertEqual(actualData.fromAddress, "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19")
        XCTAssertEqual(actualData.to, "824aa01033c89595479bab9d8deb3fc3a3e65e2d")
        XCTAssertEqual(actualData.toAddress, "NQ44 G95A 041K R2AR AHUT MEEQ TSRY QEHX CPHD")
        XCTAssertEqual(actualData.value, 418585560)
        XCTAssertEqual(actualData.fee, 138)
        XCTAssertEqual(actualData.data, nil)
        XCTAssertEqual(actualData.flags, 0)
    }
    
    func test_getTransactionByHash() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": {
                "hash": "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554",
                "blockHash": "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f",
                "blockNumber": 76415,
                "timestamp": 1528297445,
                "confirmations": 151281,
                "transactionIndex": 20,
                "from": "ad25610feb43d75307763d3f010822a757027429",
                "fromAddress": "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19",
                "to": "824aa01033c89595479bab9d8deb3fc3a3e65e2d",
                "toAddress": "NQ44 G95A 041K R2AR AHUT MEEQ TSRY QEHX CPHD",
                "value": 418585560,
                "fee": 138,
                "data": null,
                "flags": 0
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getTransactionByHash(hash: "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")!

        XCTAssertEqual(actualData.hash, "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")
        XCTAssertEqual(actualData.blockHash, "dfe7d166f2c86bd10fa4b1f29cd06c13228f893167ce9826137c85758645572f")
        XCTAssertEqual(actualData.blockNumber, 76415)
        XCTAssertEqual(actualData.timestamp, 1528297445)
        XCTAssertEqual(actualData.confirmations, 151281)
        XCTAssertEqual(actualData.transactionIndex, 20)
        XCTAssertEqual(actualData.from, "ad25610feb43d75307763d3f010822a757027429")
        XCTAssertEqual(actualData.fromAddress, "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19")
        XCTAssertEqual(actualData.to, "824aa01033c89595479bab9d8deb3fc3a3e65e2d")
        XCTAssertEqual(actualData.toAddress, "NQ44 G95A 041K R2AR AHUT MEEQ TSRY QEHX CPHD")
        XCTAssertEqual(actualData.value, 418585560)
        XCTAssertEqual(actualData.fee, 138)
        XCTAssertEqual(actualData.data, nil)
        XCTAssertEqual(actualData.flags, 0)
    }
    
    func test_getTransactionReceipt() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc":"2.0",
              "result": {
                "transactionHash": "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554",
                "transactionIndex":  1,
                "blockHash": "c6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b",
                "blockNumber": 11,
                "confirmations": 5,
                "timestamp": 1529327401
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getTransactionReceipt(hash: "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")!

        XCTAssertEqual(actualData.transactionHash, "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")
        XCTAssertEqual(actualData.transactionIndex, 1)
        XCTAssertEqual(actualData.blockHash, "c6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b")
        XCTAssertEqual(actualData.blockNumber, 11)
        XCTAssertEqual(actualData.confirmations, 5)
        XCTAssertEqual(actualData.timestamp, 1529327401)
    }
    
    func test_getTransactionsByAddress() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc":"2.0",
              "result": [
                {
                  "hash": "745e19018e785cd8f05219578cceb6620d32f9c500ea1e4e9c0e416216984fe7",
                  "blockHash": "119657593bf6ac9e2b2a46ce28cd36a016ee0277f585235297c6a1e01b918a24",
                  "blockNumber": 79569,
                  "timestamp": 1528487555,
                  "confirmations": 156156,
                  "transactionIndex": 0,
                  "from": "4a88aaad038f9b8248865c4b9249efc554960e16",
                  "fromAddress": "NQ69 9A4A MB83 HXDQ 4J46 BH5R 4JFF QMA9 C3GN",
                  "to": "ad25610feb43d75307763d3f010822a757027429",
                  "toAddress": "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19",
                  "value": 8000000000000,
                  "fee": 0,
                  "data": null,
                  "flags": 0
                }
              ]
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getTransactionsByAddress(address: "NQ69 9A4A MB83 HXDQ 4J46 BH5R 4JFF QMA9 C3GN")!

        let transaction = actualData[0]
        
        XCTAssertEqual(transaction.hash, "745e19018e785cd8f05219578cceb6620d32f9c500ea1e4e9c0e416216984fe7")
        XCTAssertEqual(transaction.blockHash, "119657593bf6ac9e2b2a46ce28cd36a016ee0277f585235297c6a1e01b918a24")
        XCTAssertEqual(transaction.blockNumber, 79569)
        XCTAssertEqual(transaction.timestamp, 1528487555)
        XCTAssertEqual(transaction.confirmations, 156156)
        XCTAssertEqual(transaction.transactionIndex, 0)
        XCTAssertEqual(transaction.from, "4a88aaad038f9b8248865c4b9249efc554960e16")
        XCTAssertEqual(transaction.fromAddress, "NQ69 9A4A MB83 HXDQ 4J46 BH5R 4JFF QMA9 C3GN")
        XCTAssertEqual(transaction.to, "ad25610feb43d75307763d3f010822a757027429")
        XCTAssertEqual(transaction.toAddress, "NQ15 MLJN 23YB 8FBM 61TN 7LYG 2212 LVBG 4V19")
        XCTAssertEqual(transaction.value, 8000000000000)
        XCTAssertEqual(transaction.fee, 0)
        XCTAssertEqual(transaction.data, nil)
        XCTAssertEqual(transaction.flags, 0)
    }
    
    func test_getWork() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": {
                "data": "00015a7d47ddf5152a7d06a14ea291831c3fc7af20b88240c5ae839683021bcee3e279877b3de0da8ce8878bf225f6782a2663eff9a03478c15ba839fde9f1dc3dd9e5f0cd4dbc96a30130de130eb52d8160e9197e2ccf435d8d24a09b518a5e05da87a8658ed8c02531f66a7d31757b08c88d283654ed477e5e2fec21a7ca8449241e00d620000dc2fa5e763bda00000000",
                "suffix": "11fad9806b8b4167517c162fa113c09606b44d24f8020804a0f756db085546ff585adfdedad9085d36527a8485b497728446c35b9b6c3db263c07dd0a1f487b1639aa37ff60ba3cf6ed8ab5146fee50a23ebd84ea37dca8c49b31e57d05c9e6c57f09a3b282b71ec2be66c1bc8268b5326bb222b11a0d0a4acd2a93c9e8a8713fe4383e9d5df3b1bf008c535281086b2bcc20e494393aea1475a5c3f13673de2cf7314d201b7cc7f01e0e6f0e07dd9249dc598f4e5ee8801f50000000000",
                "target": 503371296,
                "algorithm": "nimiq-argon2"
              },
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.getWork(address: "NQ46 NTNU QX94 MVD0 BBT0 GXAR QUHK VGNF 39ET", extraData: "")!
        
        XCTAssertEqual(actualData.data, "00015a7d47ddf5152a7d06a14ea291831c3fc7af20b88240c5ae839683021bcee3e279877b3de0da8ce8878bf225f6782a2663eff9a03478c15ba839fde9f1dc3dd9e5f0cd4dbc96a30130de130eb52d8160e9197e2ccf435d8d24a09b518a5e05da87a8658ed8c02531f66a7d31757b08c88d283654ed477e5e2fec21a7ca8449241e00d620000dc2fa5e763bda00000000")
        XCTAssertEqual(actualData.suffix, "11fad9806b8b4167517c162fa113c09606b44d24f8020804a0f756db085546ff585adfdedad9085d36527a8485b497728446c35b9b6c3db263c07dd0a1f487b1639aa37ff60ba3cf6ed8ab5146fee50a23ebd84ea37dca8c49b31e57d05c9e6c57f09a3b282b71ec2be66c1bc8268b5326bb222b11a0d0a4acd2a93c9e8a8713fe4383e9d5df3b1bf008c535281086b2bcc20e494393aea1475a5c3f13673de2cf7314d201b7cc7f01e0e6f0e07dd9249dc598f4e5ee8801f50000000000")
        XCTAssertEqual(actualData.target, 503371296)
        XCTAssertEqual(actualData.algorithm, "nimiq-argon2")
    }
    
    func test_hashrate() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": 52982.2731
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.hashrate()!
        
        XCTAssertEqual(actualData, 52982.2731)
    }
    
    func test_log() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": true,
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.log(tag: "BaseConsensus", level: LogLevel.debug)!
        
        XCTAssertEqual(actualData, true)
    }
    
    func test_mempool() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": {
                "0": 2,
                "2": 1,
                "total": 3,
                "buckets": [
                  2,
                  0
                ]
              },
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.mempool()!
        
        XCTAssertEqual(actualData.total, 3)
        XCTAssertEqual(actualData.buckets[0], 2)
        XCTAssertEqual(actualData.buckets[1], 0)
        XCTAssertEqual(actualData.transactions[0], 2)
        XCTAssertEqual(actualData.transactions[2], 1)
    }
    
    func test_mempoolContent() {
        var expectedData = """
            {
              "jsonrpc": "2.0",
              "result": [
                "5bb722c2afe25c18ba33d453b3ac2c90ac278c595cc92f6188c8b699e8fb006a",
                "9cd9c1d0ffcaebfcfe86bc2ae73b4e82a488de99c8e3faef92b05432bb94519c"
              ],
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        var actualData = client.mempoolContent()!
        
        XCTAssertEqual(actualData[0] as! String, "5bb722c2afe25c18ba33d453b3ac2c90ac278c595cc92f6188c8b699e8fb006a")
        XCTAssertEqual(actualData[1] as! String, "9cd9c1d0ffcaebfcfe86bc2ae73b4e82a488de99c8e3faef92b05432bb94519c")
        
        expectedData = """
        {
          "jsonrpc": "2.0",
          "result": [
            {
              "hash": "5bb722c2afe25c18ba33d453b3ac2c90ac278c595cc92f6188c8b699e8fb006a",
              "from": "f3a2a520967fb046deee40af0c68c3dc43ef3238",
              "fromAddress": "NQ04 XEHA A84N FXQ4 DPPE 82PG QS63 TH1X XCHQ",
              "to": "ca9e687c4e760e5d6dd4a789c577cefe1338ad2c",
              "toAddress": "NQ77 RAF6 GY2E EQ75 STEL LX4U AVXE YQ9K HB9C",
              "value": 9286543536,
              "fee": 1380,
              "data": null,
              "flags": 0
            },
            {
              "hash": "9cd9c1d0ffcaebfcfe86bc2ae73b4e82a488de99c8e3faef92b05432bb94519c",
              "from": "f3a2a520967fb046deee40af0c68c3dc43ef3238",
              "fromAddress": "NQ04 XEHA A84N FXQ4 DPPE 82PG QS63 TH1X XCHQ",
              "to": "d497b15fe0857394f3e485c87e00fa44270fcd4d",
              "toAddress": "NQ60 SJBT 2PY0 GMRR 9UY4 GP47 U07S 8GKG YKAD",
              "value": 1038143325,
              "fee": 1380,
              "data": null,
              "flags": 0
            }
          ],
          "id": 1
        }
        """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        actualData = client.mempoolContent(fullTransactions: true)!
        
        var transaction = actualData[0] as! Transaction
        
        XCTAssertEqual(transaction.hash, "5bb722c2afe25c18ba33d453b3ac2c90ac278c595cc92f6188c8b699e8fb006a")
        XCTAssertEqual(transaction.from, "f3a2a520967fb046deee40af0c68c3dc43ef3238")
        XCTAssertEqual(transaction.fromAddress, "NQ04 XEHA A84N FXQ4 DPPE 82PG QS63 TH1X XCHQ")
        XCTAssertEqual(transaction.to, "ca9e687c4e760e5d6dd4a789c577cefe1338ad2c")
        XCTAssertEqual(transaction.toAddress, "NQ77 RAF6 GY2E EQ75 STEL LX4U AVXE YQ9K HB9C")
        XCTAssertEqual(transaction.value, 9286543536)
        XCTAssertEqual(transaction.fee, 1380)
        XCTAssertEqual(transaction.data, nil)
        XCTAssertEqual(transaction.flags, 0)

        transaction = actualData[1] as! Transaction
        
        XCTAssertEqual(transaction.hash, "9cd9c1d0ffcaebfcfe86bc2ae73b4e82a488de99c8e3faef92b05432bb94519c")
        XCTAssertEqual(transaction.from, "f3a2a520967fb046deee40af0c68c3dc43ef3238")
        XCTAssertEqual(transaction.fromAddress, "NQ04 XEHA A84N FXQ4 DPPE 82PG QS63 TH1X XCHQ")
        XCTAssertEqual(transaction.to, "d497b15fe0857394f3e485c87e00fa44270fcd4d")
        XCTAssertEqual(transaction.toAddress, "NQ60 SJBT 2PY0 GMRR 9UY4 GP47 U07S 8GKG YKAD")
        XCTAssertEqual(transaction.value, 1038143325)
        XCTAssertEqual(transaction.fee, 1380)
        XCTAssertEqual(transaction.data, nil)
        XCTAssertEqual(transaction.flags, 0)
    }
    
    func test_minerAddress() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": "NQ39 NY67 X0F0 UTQE 0YER 4JEU B67L UPP8 G0FM",
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.minerAddress()!
        
        XCTAssertEqual(actualData, "NQ39 NY67 X0F0 UTQE 0YER 4JEU B67L UPP8 G0FM")
    }
    
    func test_minerThreads() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": 1,
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.minerThreads()!
        
        XCTAssertEqual(actualData, 1)
    }
    
    func test_minFeePerByte() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": 0,
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.minFeePerByte()!
        
        XCTAssertEqual(actualData, 0)
    }
    
    func test_mining() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": true
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.mining()!
        
        XCTAssertEqual(actualData, true)
    }
    
    func test_peerCount() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": 12
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.peerCount()!
        
        XCTAssertEqual(actualData, 12)
    }
    
    func test_peerList() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": [
                {
                  "id": "b99034c552e9c0fd34eb95c1cdf17f5e",
                  "address": "wss://seed1.nimiq-testnet.com:8080/b99034c552e9c0fd34eb95c1cdf17f5e",
                  "addressState": 2,
                  "connectionState": 5,
                  "version": 2,
                  "timeOffset": -188,
                  "headHash": "59da8ba57c1f0ffd444201ca2d9f48cef7e661262781be7937bb6ef0bdbe0e4d",
                  "latency": 532,
                  "rx": 2122,
                  "tx": 1265
                },
                {
                  "id": "e37dca72802c972d45b37735e9595cf0",
                  "address": "wss://seed4.nimiq-testnet.com:8080/e37dca72802c972d45b37735e9595cf0",
                  "addressState": 4
                }
              ],
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.peerList()!
        
        var peer = actualData[0]
        
        XCTAssertEqual(peer.id, "b99034c552e9c0fd34eb95c1cdf17f5e")
        XCTAssertEqual(peer.address, "wss://seed1.nimiq-testnet.com:8080/b99034c552e9c0fd34eb95c1cdf17f5e")
        XCTAssertEqual(peer.addressState, PeerAddressState.established)
        XCTAssertEqual(peer.connectionState, PeerConnectionState.established)
        XCTAssertEqual(peer.version, 2)
        XCTAssertEqual(peer.timeOffset, -188)
        XCTAssertEqual(peer.headHash, "59da8ba57c1f0ffd444201ca2d9f48cef7e661262781be7937bb6ef0bdbe0e4d")
        XCTAssertEqual(peer.latency, 532)
        XCTAssertEqual(peer.rx, 2122)
        XCTAssertEqual(peer.tx, 1265)
        
        peer = actualData[1]
        
        XCTAssertEqual(peer.id, "e37dca72802c972d45b37735e9595cf0")
        XCTAssertEqual(peer.address, "wss://seed4.nimiq-testnet.com:8080/e37dca72802c972d45b37735e9595cf0")
        XCTAssertEqual(peer.addressState, PeerAddressState.failed)
    }
    
    func test_peerState() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": {
                "id": "b99034c552e9c0fd34eb95c1cdf17f5e",
                "address": "wss://seed1.nimiq-testnet.com:8080/b99034c552e9c0fd34eb95c1cdf17f5e",
                "addressState": 2,
                "connectionState": 5,
                "version": 2,
                "timeOffset": 186,
                "headHash": "910a78e761034e0655bf01b13336793c809f598194a1b841269600ef8b84fe18",
                "latency": 550,
                "rx": 3440,
                "tx": 2696
              },
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.peerState(address: "wss://seed1.nimiq-testnet.com:8080/b99034c552e9c0fd34eb95c1cdf17f5e")!
        
        XCTAssertEqual(actualData.id, "b99034c552e9c0fd34eb95c1cdf17f5e")
        XCTAssertEqual(actualData.address, "wss://seed1.nimiq-testnet.com:8080/b99034c552e9c0fd34eb95c1cdf17f5e")
        XCTAssertEqual(actualData.addressState, PeerAddressState.established)
        XCTAssertEqual(actualData.connectionState, PeerConnectionState.established)
        XCTAssertEqual(actualData.version, 2)
        XCTAssertEqual(actualData.timeOffset, 186)
        XCTAssertEqual(actualData.headHash, "910a78e761034e0655bf01b13336793c809f598194a1b841269600ef8b84fe18")
        XCTAssertEqual(actualData.latency, 550)
        XCTAssertEqual(actualData.rx, 3440)
        XCTAssertEqual(actualData.tx, 2696)
    }
    
    func test_pool() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": "test-pool.nimiq.watch:8443",
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.pool()!
        
        XCTAssertEqual(actualData, "test-pool.nimiq.watch:8443")
    }
    
    func test_poolConfirmedBalance() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": 12000,
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.poolConfirmedBalance()!
        
        XCTAssertEqual(actualData, 12000)
    }
    
    func test_poolConnectionState() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "result": 0,
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.poolConnectionState()!
        
        XCTAssertEqual(actualData, PoolConnectionState.connected)
    }
    
    func test_sendRawTransaction() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554"
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.sendRawTransaction(transaction: "010000...abcdef")
        
        XCTAssertEqual(actualData, "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")
    }
    
    func test_sendTransaction() {
        let expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554"
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.sendTransaction(transaction: OutgoingTransaction(
            from: "NQ94 VESA PKTA 9YQ0 XKGC HVH0 Q9DF VSFU STSP",
            to: "NQ16 61ET MB3M 2JG6 TBLK BR0D B6EA X6XQ L91U",
            value: 100000,
            fee: 0
        ))
        
        XCTAssertEqual(actualData, "465a63b73aa0b9b54b777be9a585ea00b367a17898ad520e1f22cb2c986ff554")
    }
    
    func test_submitBlock() {
        let expectedData = """
            {
              "jsonrpc": "2.0",
              "id": 1
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        let actualData = client.submitBlock("000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f6ba2bbf7e1478a209057000471d73fbdc28df0b717747d929cfde829c4120f62e02da3d162e20fa982029dbde9cc20f6b431ab05df1764f34af4c62a4f2b33f1f010000000000015ac3185f000134990001000000000000000000000000000000000000000007546573744e657400000000")
        
        XCTAssertEqual(actualData, nil)
    }
    
    func test_syncing() {
        var expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": {
                "startingBlock": 1,
                "currentBlock": 12345,
                "highestBlock": 23456
              }
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData

        var actualData = client.syncing()!
        
        let syncing = actualData as! SyncStatus
        
        XCTAssertEqual(syncing.startingBlock, 1)
        XCTAssertEqual(syncing.currentBlock, 12345)
        XCTAssertEqual(syncing.highestBlock, 23456)
        
        expectedData = """
            {
              "id": 1,
              "jsonrpc": "2.0",
              "result": false
            }
            """.data(using: .utf8)
        
        URLProtocolStub.testData = expectedData
        
        actualData = client.syncing()!

        let synced = actualData as! Bool
        
        XCTAssertEqual(synced, false)
    }
}
