# go通过rfc链接SAP  

## 准备  

去SAP官网下载`nwrfc750P_7-70002752.zip` 然后解压后，打包成`nwrfcsdk.tar.gz`

```sh
# 准备SAP依赖
unzip -d nwrfcsdk nwrfc750P_7-70002752.zip
tar -czf nwrfcsdk.tar.gz nwrfcsdk
# 构建镜像
docker build -t dongdavid/gosap:latest .
# 启动容器
docker run -d -it --name gosap -p 8000:8080 -v $PWD:/data dongdavid/gosap:latest bash
```

## 需要注意的地方  

在新版本的go中(我用的是1.15.6)，使用`go get`加载`sap/gorfc`这个包的时候会出现一个错误提示,它会导致镜像构建失败,所以在Dockerfile中我使用的是`dongdavid/gorfc`来替代`sap/gorfc`
```sh
$ go get github.com/sap/gorfc
package github.com/sap/gorfc: no Go files in /go/src/github.com/sap/gorfc
```


## 手工配置SAP及GORFC  


### 安装SAP NW RFC 依赖库  

```sh
mkdir /usr/local/sap
mv nwrfcsdk/ /usr/local/sap/
echo export SAPNWRFC_HOME=/usr/local/sap/nwrfcsdk >> /.bashrc
echo /usr/local/sap/nwrfcsdk/lib >> /etc/ld.so.conf.d/nwrfcsdk.conf
ldconfig
```

### 安装GORFC  

```sh
export CGO_CFLAGS="-I $SAPNWRFC_HOME/include"
export CGO_LDFLAGS="-L $SAPNWRFC_HOME/lib"
export CGO_CFLAGS_ALLOW=.*
export CGO_LDFLAGS_ALLOW=.*
go get github.com/stretchr/testify
go get github.com/sap/gorfc
cd $GOPATH/src/github.com/sap/gorfc/gorfc
go build
go install
```

```golang
package main

import (
	"fmt"
	"github.com/sap/gorfc/gorfc"
)
func abapSystem() gorfc.ConnectionParameters {
	return gorfc.ConnectionParameters{
		"user":   "",
		"passwd": "",
		"ashost": "127.0.0.1",
		"sysnr":  "",
		"client": "",
		"lang":   "EN",
	}
}
func main() {
	c, err := gorfc.ConnectionFromParams(abapSystem())
	if err != nil {
		fmt.Println(err)
		return
	}
	fmt.Println("Connected:", c.Alive())
	params := map[string]interface{}{
		"VKORG": "xxx",
		"KUNNR": "",
	}
	r, e := c.Call("func_name", params)

	if e != nil {
		fmt.Println(e)
		return
	}
	fmt.Println(r)
	// fmt.Println(r["ZSD_KNVV"].([]interface{})[0].(map[string]interface{})["KUNN2"])
	c.Close()
}
```