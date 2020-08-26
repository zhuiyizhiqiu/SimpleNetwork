# SimpleNetwork

## 这是一个轻量级的网络框架
  可以通过SPM（Swift Package Manager）导入您的项目
  
## 通过如下方式导入包，在您的Xcode上点击左上角的file-> Swift Packages -> add Package Dependency...,然后在输入框输入如下链接
  ```
  https://github.com/zhuiyizhiqiu/SimpleNetwork.git
```

## 使用方法
   ```
    let network = SimpleNetwork.simpleNetwork
     struct data: Codable {
        var status = 0
        var msg = ""
    }
    network.request(url: "要访问的url") { (result, response: data?) in
            switch result{
            case .failure(let str):
                print(str)
            case .success:
                print(response!.status,response!.msg)
            }
        }
  ```
