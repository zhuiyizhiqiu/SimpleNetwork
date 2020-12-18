import Foundation
import SwiftyJSON

public let sn = SimpleNetwork.simpleNetwork

open class SimpleNetwork {
    public static let simpleNetwork = SimpleNetwork()
    
    static let conf = URLSessionConfiguration.default
    let session = URLSession(configuration: conf)
//    typealias T = Codable
    public typealias completion<T:Codable> =  (ResponseResult,T?) -> ()
//    typealias completion = (ResponseResult,JSON?) -> ()
    
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

    
    /// 发送网络请求，默认10s请求超时
    /// - Parameters:
    ///   - url: 传入一个字符串
    ///   - paraments: 字符串字典类型的参数，不传默认为nil
    ///   - head: 请求头里面包含的参数，字符串字典
    ///   - httpMethod: http的请求方法，enum类型，包括put，delete，post，get，不传参数，默认为get
    ///   - completion: 请求完之后返回的结果，completion包含两个返回的参数，一个是enum：包含了两种状态，分别是failure和success，failure的情况下，用enum的成员变量进行值绑定，分别绑定error处理和status的http状态码，success的情况下，则直接获取到遵循传入的对应模型的解析
    public func request<T:Codable>(url:String,paraments:Paraments? = nil,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping completion<T>){
        guard let url = makeURL(url: url, completion: completion) else{ return }
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
    
    /// 发送网络请求，默认10秒请求超时
    /// - Parameters:
    ///   - url: 传入一个字符串
    ///   - paraments: 请求体，字符串字典类型的参数，不传默认为nil
    ///   - head: 请求头里面包含的参数，字符串字典
    ///   - httpMethod: http的请求方法，enum类型，包括put，delete，post，get，不传参数，默认为get
    ///   - completion: 请求完之后返回的结果，completion包含两个返回的参数，一个是enum：包含了两种状态，分别是failure和success，failure的情况下，用enum的成员变量进行值绑定，分别绑定error处理和status的http状态码，success的情况下，则直接返回可选的json数据结构
    public func request(url: String,paraments: Paraments? = nil,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,JSON?) -> ()){
        guard let url = makeURL(url: url, completion: completion) else{ return }

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
    
    
    /// 发送网络请求，默认10s请求超时
    /// - Parameters:
    ///   - url: 传入一个字符串
    ///   - paraments: 请求体，传入遵循Codable协议的struct即可
    ///   - head: 请求头里面包含的参数，字符串字典
    ///   - httpMethod: http的请求方法，enum类型，包括put，delete，post，get，不传参数，默认为get
    ///   - completion: 请求完之后返回的结果，completion包含两个返回的参数，一个是enum：包含了两种状态，分别是failure和success，failure的情况下，用enum的成员变量进行值绑定，分别绑定error处理和status的http状态码，success的情况下，则直接返回可选的json数据结构
    /// - Returns: <#description#>
    public func request<N:Codable>(url: String,paraments:N,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping(ResponseResult,JSON?) -> ()){
        guard let url = makeURL(url: url, completion: completion) else{ return }
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
    
    /// 发送网络请求，默认10s请求超时
    /// - Parameters:
    ///   - url: 传入一个字符串
    ///   - paraments: 请求体，传入遵循Codable协议的struct即可
    ///   - head: 请求头里面包含的参数，字符串字典
    ///   - httpMethod: http的请求方法，enum类型，包括put，delete，post，get，不传参数，默认为get
    ///   - completion: 请求完之后返回的结果，completion包含两个返回的参数，一个是enum：包含了两种状态，分别是failure和success，failure的情况下，用enum的成员变量进行值绑定，分别绑定error处理和status的http状态码，success的情况下，则直接获取到遵循传入的对应模型的解析
    /// - Returns: <#description#>
    public func request<N:Codable,T:Codable>(url: String,paraments:N,head:head? = nil,httpMethod: HttpMethod = .get,completion:@escaping completion<T>){
        guard let url = makeURL(url: url, completion: completion) else{ return }
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
    
    private func makeURL<T:Codable>(url: String,completion:@escaping(ResponseResult,T?) -> ()) -> URL?{
           guard let newURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
               completion(.failure("url编码错误", nil),nil)
               return nil
           }
           guard let url = URL(string: newURL) else{
               completion(.failure("\(newURL.removingPercentEncoding!)是非法的url", nil), nil)
               return nil
           }
           
           return url
       }
    
    private func makeURL(url: String,completion:@escaping(ResponseResult,JSON?) -> ()) -> URL?{
        guard let newURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure("url编码错误", nil),nil)
            return nil
        }
        guard let url = URL(string: newURL) else{
            completion(.failure("\(newURL.removingPercentEncoding!)是非法的url", nil), nil)
            return nil
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
    
    private func dataTask<T:Codable>(request:URLRequest,completion:@escaping completion<T>){

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
