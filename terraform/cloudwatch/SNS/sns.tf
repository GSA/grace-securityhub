#SNS Topic for alarms
data "template_file" "cloudformation_sns_stack_alarms" {
  template = "${file("${path.module}/templates/email-sns-stack-alarms.json.tpl")}"

  vars {
    display_name  = "${var.display_name_alarms}"
    email_address = "${var.email_address}"
    protocol      = "${var.protocol}"
  }
}

resource "aws_cloudformation_stack" "sns-topic-alarms" {
  name          = "${var.stack_name_alarms}"
  template_body = "${data.template_file.cloudformation_sns_stack_alarms.rendered}"

  tags = "${merge(
    var.additional_tags,
    map("Name", "${var.stack_name_alarms}")
  )}"
}

#SNS Topic for events
data "template_file" "cloudformation_sns_stack" {
  template = "${file("${path.module}/templates/email-sns-stack.json.tpl")}"

  vars {
    display_name  = "${var.display_name}"
    email_address = "${var.email_address}"
    protocol      = "${var.protocol}"
  }
}

resource "aws_cloudformation_stack" "sns-topic" {
  name          = "${var.stack_name}"
  template_body = "${data.template_file.cloudformation_sns_stack.rendered}"

  tags = "${merge(
    var.additional_tags,
    map("Name", "${var.stack_name}")
  )}"
}
