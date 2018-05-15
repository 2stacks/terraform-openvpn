output "Public IPs" {
  value = "${module.do-node.node_ipv4_address}"
}

output "Node Names" {
  value = "${module.do-node.node_name}"
}
