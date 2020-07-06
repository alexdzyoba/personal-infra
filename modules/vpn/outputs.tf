output "public_ip" {
  value = aws_eip.public.public_ip
}

output "instance_id" {
  value = aws_instance.vpn.id
}

output "instance_dns" {
  value = aws_instance.vpn.public_dns
}
