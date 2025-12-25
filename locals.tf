# Local values and configuration
locals {
  # Protocol numbers for security rules
  protocol_number = {
    icmp   = 1
    icmpv6 = 58
    tcp    = 6
    udp    = 17
  }
}
