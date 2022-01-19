output "challenge_web_server_tls_private_key_pem_content" {
  value = module.challenge_web_server.tls_private_key_pem_content
  sensitive = true
  description = "tls private key content"
}

output "challenge_web_server_instance_ip_addr" {
  value       = module.challenge_web_server.instance_ip_addr
  description = "web server IP address"
}