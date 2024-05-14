package main

import (
	"fmt"
	"math/rand"
	"net/http"

	"github.com/gin-gonic/gin"
	flagd "github.com/open-feature/go-sdk-contrib/providers/flagd/pkg"
	"github.com/open-feature/go-sdk/openfeature"
)

const (
	flagName         = "hello_variants_world"
	flagTargetingKey = "email"
)

type HelloResponse struct {
	User    string `json:"user"`
	Reason  string `json:"reason"`
	Variant string `json:"variant"`
	Value   string `json:"value"`
	Err     string `json:"err,omitempty"`
}

func main() {
	provider := flagd.NewProvider()
	openfeature.SetProvider(provider)
	client := openfeature.NewClient("GoStartApp")
	engine := gin.Default()

	engine.GET("/hello", func(ctx *gin.Context) {
		fakeEmail := ctx.DefaultQuery("email", fmt.Sprintf("%d@ecorp.com", rand.Int()))
		flagContext := openfeature.NewEvaluationContext(flagTargetingKey, map[string]any{
			flagTargetingKey: fakeEmail,
		})

		flagEvaluation, flagError := client.StringValueDetails(ctx, flagName, "blue", flagContext)
		httpBody := HelloResponse{
			User:    fakeEmail,
			Variant: flagEvaluation.Variant,
			Value:   flagEvaluation.Value,
			Reason:  string(flagEvaluation.Reason),
		}

		if flagError != nil {
			httpBody.Err = flagError.Error()
		}

		ctx.JSON(http.StatusOK, httpBody)
	})

	engine.Run()
}
