package event

import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/securityhub"
	"github.com/aws/aws-sdk-go/service/sts"
	"strconv"
)

// Event ... holds raw CloudWatch event data
type Event map[string]interface{}

// Type ... interface for creating custom Event matchers
type Type interface {
	Is(Event) bool
	Init(*Processor)
	Finding(Event) *securityhub.AwsSecurityFinding
}

var types []Type

// Register ... registers the given Type objects for use as Event matchers
// Type objects are sequentially called, so order matters
func Register(typ ...Type) {
	for _, t := range typ {
		types = append(types, t)
	}
}

// Processor ... is used for retaining state data for processing Event objects
type Processor struct {
	sess  *session.Session
	ident *sts.GetCallerIdentityOutput
}

// New ... returns a new *Processor
func New() (p *Processor, err error) {
	p.sess = session.Must(session.NewSession())
	p.ident, err = p.identity()
	return
}

// Publish ... calls securityhub.BatchImportFindings providing the results from
// calling Type.Finding(Event) on each provided Event, returns an error upon failure
func (p *Processor) Publish(evt ...Event) error {
	var findings []*securityhub.AwsSecurityFinding
	if len(evt) == 0 {
		return errors.New("failed to publish, at least one Event must be provided")
	}
	for _, e := range evt {
		t := e.Type()
		if t == nil {
			return fmt.Errorf("event type not supported: %v", e)
		}
		t.Init(p)
		findings = append(findings, t.Finding(e))
	}
	err := p.publish(findings...)
	return err
}

// publish ... batch imports one or more SecurityHub findings
func (p *Processor) publish(findings ...*securityhub.AwsSecurityFinding) error {
	svc := securityhub.New(p.sess)
	output, err := svc.BatchImportFindings(&securityhub.BatchImportFindingsInput{
		Findings: findings,
	})
	if int64(len(findings)) != aws.Int64Value(output.SuccessCount) {
		msg := fmt.Sprintf("failed to publish %d finding(s)", aws.Int64Value(output.FailedCount))
		for _, f := range output.FailedFindings {
			msg = fmt.Sprintf("%s\nError: %s, Msg: %s",
				msg,
				aws.StringValue(f.ErrorCode),
				aws.StringValue(f.ErrorMessage))
		}
		msg = fmt.Sprintf("%s -> %v\n", msg, err)
		return errors.New(msg)
	}
	return nil
}

// identity ... returns the current AWS identity
func (p *Processor) identity() (*sts.GetCallerIdentityOutput, error) {
	svc := sts.New(p.sess)
	return svc.GetCallerIdentity(&sts.GetCallerIdentityInput{})
}

// ProductArn ... returns the value for the default SecurityHub Arn
// format: arn:aws:securityhub:<region>:<account-id>:product/<account-id>/default
func (p *Processor) ProductArn() string {
	return fmt.Sprintf("aws:aws:securityhub:%s:%s:product/%s/default",
		aws.StringValue(p.sess.Config.Region),
		aws.StringValue(p.ident.Account),
		aws.StringValue(p.ident.Account))
}

// Flatten ... flattens an Event to a single-level map appending subsequent
// keys and zero-indexed array elements with '.' as the delimiter
func (e Event) Flatten() Event {
	return flatten(e)
}

// Type ... calls Type.Is(Event) on each registered Type, returning the first Type
// that matches the provided Event type or nil if no matching Type is found
func (e Event) Type() Type {
	for _, t := range types {
		if t.Is(e) {
			return t
		}
	}
	return nil
}

// nolint: gocyclo
// flatten ... flattens a map[string]interface{} delimiting subsequent
// keys with a period, arrays have their index appended to the key name
// in the same fashion
func flatten(m map[string]interface{}) map[string]interface{} {
	o := make(map[string]interface{})
	for k, v := range m {
		switch obj := v.(type) {
		case []interface{}:
			o[k+".length"] = len(obj)
			for i, v := range obj {
				m := make(map[string]interface{})
				m[strconv.Itoa(i)] = v
				mm := flatten(m)
				for kk, vv := range mm {
					o[k+"."+kk] = vv
				}
			}
		case float64:
			if obj == float64(int(obj)) {
				o[k] = int(obj)
				break
			}
			o[k] = obj
		case string:
			if len(obj) > 0 && obj[0] == '{' {
				mm := make(map[string]interface{})
				err := json.Unmarshal([]byte(obj), &mm)
				if err != nil {
					o[k] = obj
					break
				}
				mmm := flatten(mm)
				for kk, vv := range mmm {
					o[k+"."+kk] = vv
				}
				break
			}
			o[k] = v
		case map[string]interface{}:
			mm := flatten(obj)
			for kk, vv := range mm {
				o[k+"."+kk] = vv
			}
		case nil:
			break
		default:
			o[k] = v
		}
	}
	return o
}
