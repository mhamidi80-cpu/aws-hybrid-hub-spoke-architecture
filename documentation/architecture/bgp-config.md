# Hybrid Networking Technical Specifications

## BGP & IPsec Logic
- **Customer Gateway ASN:** 65000 (Paris Data Center)
- **AWS Side ASN:** 64512
- **Encryption:** AES-256-GCM
- **Integrity:** SHA2-256
- **DH Group:** 14

## Traffic Inspection Flow
All Egress and Hybrid traffic is routed via a "Hairpin" through the AWS Network Firewall located in the Hub VPC. This ensures a Zero-Trust posture for Mohamed Hamidi Consulting.
