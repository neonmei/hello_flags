package main

import (
	"net/http"

	"github.com/gin-gonic/gin"
	flagd "github.com/open-feature/go-sdk-contrib/providers/flagd/pkg"
	"github.com/open-feature/go-sdk/openfeature"
)

const (
	flagName            = "hello_boolean_world"
	flagMessageDisabled = "Hello! feature is disabled and you get normal experience."
	flagMessageEnabled  = "Hello Friend! you feature is enabled and you get new supersecret experience :D"
)

func main() {
	provider := flagd.NewProvider()
	openfeature.SetProvider(provider)

	client := openfeature.NewClient("GoStartApp")
	engine := gin.Default()

	engine.GET("/hello", func(ctx *gin.Context) {
		if welcomeMessage, _ := client.BooleanValue(ctx, flagName, false, openfeature.EvaluationContext{}); welcomeMessage {
			ctx.String(http.StatusOK, flagMessageEnabled)
			return
		} else {
			ctx.String(http.StatusOK, flagMessageDisabled)
			return
		}
	})

	engine.Run()
}
