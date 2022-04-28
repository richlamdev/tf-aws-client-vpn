output "Private_IPv4_addresses" {
  value       = aws_instance.private_test[0].private_ip
  description = "private IP"
}
