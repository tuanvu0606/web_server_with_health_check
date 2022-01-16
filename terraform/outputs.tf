output "tls_private_key_pem_content" {
  value = tls_private_key.challenge_tpk.private_key_pem
  sensitive = true
}

output "instance_ip_addr" {
  value = aws_instance.challeng_ec2.public_ip
}