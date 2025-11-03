resource "aws_key_pair" "test_key" {
  key_name   = "test-key"
  public_key = file("~/.ssh/test-key.pub")
}