output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public.id, aws_subnet.public_2nd.id]
}

output "private_subnet_ids" {
  description = "IDs des subnets privés pour EKS"
  value       = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}