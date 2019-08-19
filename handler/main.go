package main

import (
	"context"

	"github.com/GSA/grace-securityhub/handler/event"
	"github.com/GSA/grace-securityhub/handler/types"
	"github.com/aws/aws-lambda-go/lambda"
)

type lambdaFunction struct{}

// Invoke ... starts the lambda invocation
func (l lambdaFunction) Invoke(ctx context.Context, data []byte) ([]byte, error) {
	evt, err := event.RawEvent(data).Event()
	if err != nil {
		return nil, err
	}
	event.Register(

		// Generic should be the final type registered as it always matches
		&types.Generic{},
	)
	p, err := event.New()
	if err != nil {
		return nil, err
	}
	err = p.Publish(evt)
	if err != nil {
		return nil, err
	}
	return []byte{}, nil
}

func main() {
	lambda.StartHandler(lambdaFunction{})
}
