package types

import (
	"testing"
)

func TestStringify(t *testing.T) {
	tt := []struct {
		name     string
		data     map[string]interface{}
		expected map[string]string
	}{
		{name: "testNumbers", data: testData1, expected: testExp1},
	}
	for _, tc := range tt {
		actual := stringify(tc.data)
		for k, v := range actual {
			if tc.expected[k] != *v {
				t.Errorf("failed to match key: %s, expected: %s, got: %s", k, tc.expected[k], *v)
			}
		}
	}
}

var testData1 = map[string]interface{}{
	"a.length":          1,
	"a.0.aa.aaa.length": 3,
	"a.0.aa.aaa.0.aaaa": 1.01,
	"a.0.aa.aaa.1.aaab": 2.500,
	"a.0.aa.aaa.2.aaac": 1.000,
}
var testExp1 = map[string]string{
	"a.length":          "1",
	"a.0.aa.aaa.length": "3",
	"a.0.aa.aaa.0.aaaa": "1.01",
	"a.0.aa.aaa.1.aaab": "2.5",
	"a.0.aa.aaa.2.aaac": "1",
}
