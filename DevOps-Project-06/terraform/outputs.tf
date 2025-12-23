output "ansible_controller_ip" {
  value = aws_instance.ansible_controller.public_ip
}

output "jenkins_master_ip" {
  value = aws_instance.jenkins_master.public_ip
}

output "jenkins_agent_ip" {
  value = aws_instance.jenkins_agent.public_ip
}