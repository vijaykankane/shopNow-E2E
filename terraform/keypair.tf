# key_pair.tf

# Option A: create a key pair from your provided OpenSSH public key
resource "aws_key_pair" "generated" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_pair_name
  public_key = var.public_key_openssh

  tags = {
    Name = var.key_pair_name
  }
}

# Option B: reference an existing key pair by name (no resource created)
//data "aws_key_pair" "existing" {
  //count    = var.create_key_pair ? 0 : 1
  //key_name = var.key_pair_name
//}