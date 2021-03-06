package types

import (
	"fmt"
	"strconv"
	"sync"

	"github.com/GSA/grace-securityhub/handler/event"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/securityhub"
)

// Generic ... holds state data for the Generic event.Type matcher
type Generic struct {
	muInit    sync.Mutex
	init      bool
	processor *event.Processor
}

// Init ... performs initialization for the Generic event.Type matcher
func (g *Generic) Init(p *event.Processor) {
	g.muInit.Lock()
	defer g.muInit.Unlock()

	if g.init {
		return
	}
	// Do initialization things
	//
	g.processor = p
	g.init = true
}

// Is ... determines if a given event.Event matches the Generic type
// always returns true, should be the last Type registered
func (g *Generic) Is(evt event.Event) bool {
	return true
}

const schemaVersion = "0.0.1"

// Finding ... converts an event.Event into a Generic *securityhub.AwsSecurityFinding
// with Finding.Type 'Unusual Behaviors/Data'
func (g *Generic) Finding(evt event.Event) *securityhub.AwsSecurityFinding {
	e := evt.Flatten()
	return &securityhub.AwsSecurityFinding{
		AwsAccountId: stringifyValue(evt["recipientAccountId"]),
		CreatedAt:    stringifyValue(evt["eventTime"]),
		UpdatedAt:    stringifyValue(evt["eventTime"]),
		Title:        aws.String("Generic Finding"),
		Description:  aws.String("Generic Finding"),
		GeneratorId:  aws.String("Generic Finding Rule"),
		Id:           aws.String("GenericFinding-v" + schemaVersion),
		ProductArn:   aws.String(g.processor.ProductArn()),
		RecordState:  aws.String("ACTIVE"),
		Resources: []*securityhub.Resource{
			{
				Details: &securityhub.ResourceDetails{
					Other: stringify(e),
				},
			},
		},
		SchemaVersion: aws.String(schemaVersion),
		Severity:      &securityhub.Severity{Normalized: aws.Int64(0)},
		Types:         []*string{aws.String("Unusual Behaviors/Data")},
	}
}

func stringify(m map[string]interface{}) map[string]*string {
	o := make(map[string]*string)
	for k, v := range m {
		switch obj := v.(type) {
		case int:
			o[k] = aws.String(strconv.Itoa(obj))
		case float64:
			o[k] = aws.String(strconv.FormatFloat(obj, 'f', -1, 64))
		case string:
			o[k] = aws.String(obj)
		case map[string]interface{}:
			mm := stringify(obj)
			for kk, vv := range mm {
				o[kk] = vv
			}
		case nil:
			break
		default:
			o[k] = aws.String(fmt.Sprintf("%v", obj))
		}
	}
	return o
}

func stringifyValue(v interface{}) *string {
	switch obj := v.(type) {
	case int:
		return aws.String(strconv.Itoa(obj))
	case float64:
		return aws.String(strconv.FormatFloat(obj, 'f', -1, 64))
	case string:
		return aws.String(obj)
	case nil:
		return aws.String("")
	default:
		return aws.String(fmt.Sprintf("%v", obj))
	}
}
