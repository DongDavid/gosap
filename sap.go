package main

import (
	"fmt"
	"github.com/sap/gorfc/gorfc"
)

func abapSystem() gorfc.ConnectionParameters {
	return gorfc.ConnectionParameters{
		"user":   "",
		"passwd": "",
		"ashost": "172.1.0.1",
		"sysnr":  "",
		"client": "",
		"lang":   "ZH",
	}
}

func main(){
    c, _ := gorfc.ConnectionFromParams(abapSystem())

    params := map[string]interface{}{
        "PARAM1": "",
        "PARAM2": "",
    }
    r, _ := c.Call("FUNC_NAME", params)
    fmt.Println(r)
    c.Close()
}
