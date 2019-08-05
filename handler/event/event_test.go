package event

import (
	"encoding/json"
	"testing"
)

func TestFlatten(t *testing.T) {
	tt := []struct {
		name     string
		data     string
		expected map[string]interface{}
	}{
		{name: "testSlicesAndMaps", data: flattenData1, expected: flattenExp1},
		{name: "testFloatConversion", data: flattenData2, expected: flattenExp2},
		{name: "testOmitEmpty", data: flattenData3, expected: flattenExp3},
		{name: "testUnescapeMap", data: flattenData4, expected: flattenExp4},
	}
	for _, tc := range tt {
		var e Event
		err := json.Unmarshal([]byte(tc.data), &e)
		if err != nil {
			t.Fatalf("failed to unmarshal data: %v", err)
		}
		e = e.Flatten()
		if len(e) != len(tc.expected) {
			t.Errorf("Test: %s failed expected %d keys, got %d keys -> %v", tc.name, len(tc.expected), len(e), e)
			continue
		}
		for key, expected := range tc.expected {
			if actual, ok := e[key]; ok {
				if actual != expected {
					t.Errorf("Test: %s failed when comparing [key: %s] got: [%T: %v], expected: [%T: %v]",
						tc.name, key, actual, actual, expected, expected)
				}
				continue
			}
			t.Errorf("Test: %s failed because key: %s does not exist in actual -> %v", tc.name, key, e)
		}
		for k, v := range e {
			t.Logf("%s: %v\n", k, v)
		}
	}
}

var flattenData1 = `{"a":[{"aa":{"aaa":[{"aaaa":"a"},{"aaab":"b"},{"aaac":"c"}]}}]}`
var flattenExp1 = map[string]interface{}{
	"a.length":          1,
	"a.0.aa.aaa.length": 3,
	"a.0.aa.aaa.0.aaaa": "a",
	"a.0.aa.aaa.1.aaab": "b",
	"a.0.aa.aaa.2.aaac": "c",
}
var flattenData2 = `{"a":1.0,"b":1.2,"c":1234567890.000000000}`
var flattenExp2 = map[string]interface{}{
	"a": 1,
	"b": float64(1.2),
	"c": 1234567890,
}

var flattenData3 = `{"a":"a", "b":null, "c":""}`
var flattenExp3 = map[string]interface{}{
	"a": "a",
	"c": "",
}

//nolint: lll
var flattenData4 = `{"a":"a", "b":"{\"aa\":null,\"bb\":[{\"aaa\":{\"aaaa\":\"aaaa\",\"aaab\":null},\"aab\":\"aab\"},{\"bbb\":{\"aaaa\":\"aaaa\",\"aaab\":null},\"bbc\":\"bbc\"}]}"}`
var flattenExp4 = map[string]interface{}{
	"a":               "a",
	"b.bb.length":     2,
	"b.bb.0.aaa.aaaa": "aaaa",
	"b.bb.0.aab":      "aab",
	"b.bb.1.bbb.aaaa": "aaaa",
	"b.bb.1.bbc":      "bbc",
}
