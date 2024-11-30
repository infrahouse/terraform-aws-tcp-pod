resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "default" {
  public_key = tls_private_key.rsa.public_key_openssh
  tags = merge(
    local.default_module_tags,
    {
      in-use : var.key_pair_name == null
    }
  )
}
