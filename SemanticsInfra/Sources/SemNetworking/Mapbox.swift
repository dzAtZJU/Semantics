import Combine
import Foundation

//https://docs.mapbox.com/help/troubleshooting/uploads/#errors
public enum Mapbox {
    
    public struct GetAWSCredentialsRep:Decodable {
        public let accessKeyId: String
        public let secretAccessKey: String
        public let sessionToken: String
        public let bucket: String
        public let key: String
        public let url: String
    }
    
    public static func getAWSCredentials(account: Account) -> AnyPublisher<Mapbox.GetAWSCredentialsRep, Error> {
        let urlStr = "https://api.mapbox.com/uploads/v1/\(account.userName)/credentials?access_token=\(account.secretAccessToken)"
        let url = URL(string: urlStr)!
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        return URLSession.shared
            .dataTaskPublisher(for: urlReq)
            .tryMap() { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return element.data
            }
            .decode(type: GetAWSCredentialsRep.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    public struct Account {
        public init(userName: String, secretAccessToken: String) {
            self.userName = userName
            self.secretAccessToken = secretAccessToken
        }
        
        let userName: String
        public let secretAccessToken: String
    }
    
    public struct UploadReq {
        public init(key: String, bucket: String, tilesetName: String) {
            self.key = key
            self.bucket = bucket
            self.tilesetName = tilesetName
        }
        
        let key: String
        let bucket: String
        let tilesetName: String
    }
    
    public struct UploadRep: Decodable {
        public let id: String
        public let error: String?
    }
    
    public static func upload(_ req: UploadReq, account: Account) -> AnyPublisher<Mapbox.UploadRep, Error> {
        
        let urlStr = "https://api.mapbox.com/uploads/v1/\(account.userName)?access_token=\(account.secretAccessToken)"
        let url = URL(string: urlStr)!
        var urlReq = URLRequest(url: url)
        urlReq.httpMethod = "POST"
        urlReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonObj = [
            "url": "http://\(req.bucket).s3.amazonaws.com/\(req.key)",
            "tileset": "\(account.userName).\(req.tilesetName)"
        ]
        urlReq.httpBody = try! JSONSerialization.data(withJSONObject: jsonObj)
        return URLSession.shared
            .dataTaskPublisher(for: urlReq)
            .tryMap() { element -> Data in
                let httpResponse = element.response as! HTTPURLResponse
                guard httpResponse.statusCode == 201 else {
                    let body = try? JSONSerialization.jsonObject(with: element.data)
                    fatalError("fial to upload: \(httpResponse.statusCode) \(body ?? "empty")")
                }
                    
                return element.data
            }
            .decode(type: UploadRep.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}
