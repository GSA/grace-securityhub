output alarm_actions {
  value = "${aws_cloudformation_stack.sns-topic.outputs}"
}

output alarm_actions_alarms {
  value = "${aws_cloudformation_stack.sns-topic-alarms.outputs}"
}
