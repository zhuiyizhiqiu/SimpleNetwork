# SimpleNetwork

## 这是一个轻量级的网络框架
  可以通过SPM（Swift Package Manager）导入您的项目
  
## 通过如下方式导入包，在您的Xcode上点击左上角的file-> Swift Packages -> add Package Dependency...,然后在输入框输入如下链接
  ```
  https://github.com/zhuiyizhiqiu/SimpleNetwork.git
```


## 直接获取k-v,就算url里面包含汉字字符也可以自动解析，无需其他任何操作，默认是get请求
  首先要引入框架

  ```
    import SimpleNetwork
  ```
  ```
          sn.request(url: "https://www.sojson.com/api/qqmusic/8446666/json") { (result,dic) in
            switch result{
            case .failure(let error,_):
                print(error)
            case .success:
                print(dic!)
            }
        }

        sn.request(url: "http://api.qingyunke.com/api.php?key=free&appid=0&msg=北京天气") { (result,dic) in
            switch result{
            case .failure(let error,_):
                print("error =",error)
            case .success:
                print("返回键值对",dic!)
            }
        }
  ```
  
  ## 使用方法,直接用Codable协议进行解析数据
   ```
     struct data: Codable {
        var status = 0
        var msg = ""
    }
    sn.request(url: "要访问的url") { (result, response: data?) in
            switch result{
            case .failure(let str,_):
                print(str)
            case .success:
                print(response!.status,response!.msg)
            }
        }
  ```
## 带有请求头的使用方法
   ```
        let head = [
            "token" : "eyJhbGciOiJIUzI1NiJ9.eyJjcmVhdGVUaW1lIjoxNTk4NTkyOTgxNTY0LCJ0b2tlblZlcnNpb24iOjYsInBvd2VyIjoxMCwidXNlcklkIjoyfQ.v7j7K4PNwLyTpwUcc_UmGYdrUTU16il_orECivCzWR4"
          ]
        sn.request(url: "http://www.youapi.com",head: head) { (result, dic) in
            switch result{
            case .failure(let error, _):
                print("error =",error)
            case .success:
                print(dic!)
            }
        }
   ```
   
## 多参数请求的使用方法
   ```
    let paraments = [
       "user" : "youname",
       "pasword": "12345"
      ]
    sn.request(url: "http://www.youapi.com",paraments: paraments,httpMethod: .post) { (result, dic) in
        switch result{
        case .failure(let error, _):
            print("error =",error)
        case .success:
            print(dic!)
        }
    }
   ```

## 发送照片的请求方法
   ```
    let image = UIImage(named: "yourImageName")
    let imagesString = image!.jpegData(compressionQuality: 0.1)!.base64EncodedString()
    let paraments = [
        "image" : imagesString
    ]
    sn.request(url: "http://www.youapi.com",paraments: paraments,httpMethod: .post) { (result, dic) in
        switch result{
        case .failure(let error, _):
            print("error =",error)
        case .success:
            print(dic!)
        }
    }
   ```

