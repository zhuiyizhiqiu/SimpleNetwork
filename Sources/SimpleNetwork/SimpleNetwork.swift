import Foundation
import SwiftyJSON

public let sn = SimpleNetwork.simpleNetwork

open class SimpleNetwork {
    public static let simpleNetwork = SimpleNetwork()
    
    static let conf = URLSessionConfiguration.default
    let session = URLSession(configuration: conf)
    
    public enum HttpMethod {
            case post
            case get
            case delete
            case put
        }
        
   public enum ResponseResult{
        case failure(String,Int?)
        case success
    }
    
    public typealias Paraments = [String:String]
    
    public typealias head = [String:String]
    public var timeOut:TimeInterval = 10

    public func request<T:Codable>(url:String,paraments:Paraments? = nil,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,T?) -> ()){
        let url = makeURL(url: url, completion: completion)
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOut)
        request.httpMethod = HTTPMethod(httpRequest: httpMethod)
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
       let url = makeURL(url: url, completion: completion)

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOut)
        request.httpMethod = HTTPMethod(httpRequest: httpMethod)
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
    
    
    public func request<N:Codable>(url: String,paraments:N,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,JSON?) -> ()){
        let url = makeURL(url: url, completion: completion)
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOut)
        request.httpMethod = HTTPMethod(httpRequest: httpMethod)
        
        if head != nil{
            headParaments(request: &request, paramments: head!)
        }
        do {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(paraments)
            dataTask(request: request, completion: completion)
        } catch  {
            print(error.localizedDescription)
            completion(.failure(error.localizedDescription, nil), nil)
        }
        
    }
    
    public func request<N:Codable,T:Codable>(url: String,paraments:N,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,T?) -> ()){
        let url = makeURL(url: url, completion: completion)
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeOut)
        request.httpMethod = HTTPMethod(httpRequest: httpMethod)
        if head != nil{
            headParaments(request: &request, paramments: head!)
        }
        do {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(paraments)
            dataTask(request: request, completion: completion)
        } catch  {
            print(error.localizedDescription)
            completion(.failure(error.localizedDescription, nil), nil)
        }

    }

}

extension SimpleNetwork{
    
    private func makeURL<T:Codable>(url: String,completion:@escaping(ResponseResult,T)) -> URL{
           guard let newURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
               completion(.failure("url编码错误", nil),nil)
               return
           }
           guard let url = URL(string: newURL) else{
               completion(.failure("\(newURL.removingPercentEncoding!)是非法的url", nil), nil)
               return
           }
           
           return url
       }
    
    private func HTTPMethod(httpRequest: HttpMethod) -> String{
        switch httpRequest {
               case .post:
                   return "POST"
               case .get:
                   return "GET"
               case .delete:
                  return "DELETE"
                case .put:
                  return "PUT"
           }
    }
    
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
                completion(.failure(error!.localizedDescription, nil), nil)
                return
            }
            guard let httpRespose = response as? HTTPURLResponse,httpRespose.statusCode == 200,let jsonData = data else{
                completion(.failure("网络错误", (response as? HTTPURLResponse)?.statusCode), nil)
                return
            }
            
            do{
                let resourse = try JSONDecoder().decode(T.self, from: jsonData)
                completion(.success, resourse)
            }catch let error{
                completion(.failure(error.localizedDescription, nil), nil)
            }
        }
        task.resume()
    }
    
    private func dataTask(request: URLRequest,completion: @escaping(ResponseResult,JSON?) -> ()){
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else{
                completion(.failure(error!.localizedDescription, nil),nil)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200,let jsonData = data else{
                completion(.failure("网络错误",(response as? HTTPURLResponse)?.statusCode),nil)
                return
            }
            
            do{
                let dic = try JSON(data:jsonData)
                completion(.success,dic)
            }catch let error{
                completion(.failure(error.localizedDescription, nil),nil)
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
