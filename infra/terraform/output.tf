output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "appserver_private_ip" {
  value = [ for server in aws_instance.appserver: server.private_ip]
}

output "primary_db_endpoint" {
  value = aws_db_instance.primary.endpoint
}
