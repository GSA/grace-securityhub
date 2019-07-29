package main

import (
	"github.com/GSA/grace-securityhub/handler/event"
	"github.com/GSA/grace-securityhub/handler/types"
	"github.com/aws/aws-lambda-go/lambda"
)

func handler(evt event.Event) error {
	event.Register(

		// Generic should be the final type registered as it always matches
		&types.Generic{},
	)
	p, err := event.New()
	if err != nil {
		return err
	}
	err = p.Publish(evt)
	if err != nil {
		return err
	}
	return nil
}

func main() {
	lambda.Start(handler)
}
