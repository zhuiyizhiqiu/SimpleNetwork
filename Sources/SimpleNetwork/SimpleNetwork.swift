import Foundation
import SwiftyJSON

open class SimpleNetwork {
    public static let simpleNetwork = SimpleNetwork()
    
    static let conf = URLSessionConfiguration.default
    let session = URLSession(configuration: conf)
    
    public enum HttpMethod {
            case post
            case get
            case delete
        }
        
       public enum ResponseResult{
            case failure(String)
            case success
        }
        
        public typealias Paraments = [String:String]
        
        public typealias head = [String:String]
        public var timeOut:TimeInterval = 10
        
        public func request<T:Codable>(url:String,paraments:Paraments? = nil,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,T?) -> ()){
            guard let url = URL(string: url) else{
                completion(.failure("url 解析错误"), nil)
                return
            }
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOut)
            if head != nil{
                headParaments(request: &request, paramments: head!)
            }
            
            if paraments != nil{
                let boundary = "Boundary-\(UUID().uuidString)"
                request.setValue("multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type")
                request.httpBody = try! createBody(with: paraments!, boundary: boundary)
            }
            
            dataTask(request: request, completion: completion)
            
        }
    
    public func request(url: String,paraments: Paraments? = nil,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,JSON?) -> ()){
        guard let url = URL(string: url) else {
            completion(.failure("url 解析错误"),nil)
            return
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOut)
        if head != nil{
            headParaments(request: &request, paramments: head!)
        }
        
        if paraments != nil{
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type")
            request.httpBody = try! createBody(with: paraments!, boundary: boundary)
        }
        
        dataTask(request: request, completion: completion)
    }

}

extension SimpleNetwork{
    private func headParaments(request: inout URLRequest,paramments: head!){
        for i in paramments!{
            request.addValue(i.value, forHTTPHeaderField: i.key)
        }
    }
    
    private func createBody(with parameters:[String: String],boundary: String) throws -> Data{
        var body = Data()
        //添加普通参数数据
        for (key, value) in parameters {
            // 数据之前要用 --分隔线 来隔开 ，否则后台会解析失败
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func dataTask<T:Codable>(request:URLRequest,completion:@escaping(ResponseResult,T?) -> ()){

        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                completion(.failure(error!.localizedDescription), nil)
                return
            }
            guard let httpRespose = response as? HTTPURLResponse,httpRespose.statusCode == 200,let jsonData = data else{
                completion(.failure("网络错误"), nil)
                return
            }
            
            do{
                let resourse = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success, resourse)
            }catch let error{
                completion(.failure(error.localizedDescription), nil)
            }
        }
        task.resume()
    }
    
    private func dataTask(request: URLRequest,completion: @escaping(ResponseResult,JSON?) -> ()){
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                completion(.failure(error!.localizedDescription),nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,let jsonData = data else{
                completion(.failure("\(String(describing: (response as? HTTPURLResponse)?.statusCode))"),nil)
                return
            }
            
            do{
                let dic = try JSON(data:jsonData)
                completion(.success,dic)
            }catch let error{
                completion(.failure(error.localizedDescription),nil)
            }
        }
        task.resume()
    }

}

extension Data {
        //增加直接添加String数据的方法
        mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
            if let data = string.data(using: encoding) {
                append(data)
            }
        }
    }
