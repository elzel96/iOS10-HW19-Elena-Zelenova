import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG

func getData(urlRequest: String) {
    let urlRequest = URL(string: urlRequest)
    
    guard let url = urlRequest else {
        print("Invalid URL")
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        if let error = error {
            print("Error: \(error.localizedDescription)")
        } else if let response = response as? HTTPURLResponse, response.statusCode - response.statusCode%100 == 200 {
            print("Response code: \(response.statusCode)")
           
            guard let data = data else {
                print("No data received from server")
                return
            }
            
            print(String(decoding: data, as: UTF8.self))
        }
    }.resume()
}

func MD5(string: String) -> Data {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        let messageData = string.data(using:.utf8)!
        var digestData = Data(count: length)

        _ = digestData.withUnsafeMutableBytes { digestBytes -> UInt8 in
            messageData.withUnsafeBytes { messageBytes -> UInt8 in
                if let messageBytesBaseAddress = messageBytes.baseAddress, let digestBytesBlindMemory = digestBytes.bindMemory(to: UInt8.self).baseAddress {
                    let messageLength = CC_LONG(messageData.count)
                    CC_MD5(messageBytesBaseAddress, messageLength, digestBytesBlindMemory)
                }
                return 0
            }
        }
        return digestData
    }

let ts = 1
let privateKey = "c8e0726564477b1d8d7363c92a8ce33205288f09"
let publicKey = "d1f0ddc73668f1ef8f98913382c79f94"
let characterId = 1010745

let md5Data = MD5(string:"\(ts)\(privateKey)\(publicKey)")
let md5Hex =  String(md5Data.map { String(format: "%02hhx", $0) }.joined())

let urlRequest = "https://meowfacts.herokuapp.com/"

let marvelUrlRequest = "https://gateway.marvel.com/v1/public/characters/\(characterId)?ts=\(ts)&apikey=\(publicKey)&hash=\(md5Hex)"

getData(urlRequest: urlRequest)
getData(urlRequest: marvelUrlRequest)

