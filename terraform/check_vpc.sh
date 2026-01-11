#!/bin/bash

VPC_ID="vpc-085e8b2fb4945e6b5"

echo "========================================="
echo "🔍 Verificando SUBNETS"
echo "========================================="
aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --query "Subnets[].{ID:SubnetId,State:State}"

echo -e "\n========================================="
echo "🔍 Verificando ROUTE TABLES"
echo "========================================="
aws ec2 describe-route-tables --filters Name=vpc-id,Values=$VPC_ID --query "RouteTables[].{ID:RouteTableId,Assoc:Associations,Routes:Routes}"

echo -e "\n========================================="
echo "🔍 Verificando NETWORK INTERFACES (ENIs)"
echo "========================================="
aws ec2 describe-network-interfaces --filters Name=vpc-id,Values=$VPC_ID

echo -e "\n========================================="
echo "🔍 Verificando SECURITY GROUPS"
echo "========================================="
aws ec2 describe-security-groups --filters Name=vpc-id,Values=$VPC_ID --query "SecurityGroups[].{ID:GroupId,Name:GroupName}"

echo -e "\n========================================="
echo "🔍 Verificando INTERNET GATEWAYS"
echo "========================================="
aws ec2 describe-internet-gateways --filters Name=attachment.vpc-id,Values=$VPC_ID

echo -e "\n========================================="
echo "🔍 Verificando VPC ENDPOINTS"
echo "========================================="
aws ec2 describe-vpc-endpoints --filters Name=vpc-id,Values=$VPC_ID

echo -e "\n========================================="
echo "🔍 Verificando DHCP OPTIONS"
echo "========================================="
aws ec2 describe-vpcs --vpc-ids $VPC_ID --query "Vpcs[].DhcpOptionsId"

echo -e "\n========================================="
echo "🔍 Verificando NETWORK ACLs"
echo "========================================="
aws ec2 describe-network-acls --filters Name=vpc-id,Values=$VPC_ID

echo -e "\n========================================="
echo "🔍 Verificando ELBv2 LOAD BALANCERS"
echo "========================================="
aws elbv2 describe-load-balancers --query "LoadBalancers[]"

echo -e "\n========================================="
echo "🔍 Verificando CLASSIC ELBs"
echo "========================================="
aws elb describe-load-balancers --query "LoadBalancerDescriptions[]"

echo -e "\n========================================="
echo "🔍 Verificando EIPs associadas"
echo "========================================="
aws ec2 describe-addresses --query "Addresses[].{IP:PublicIp,ENI:NetworkInterfaceId,Assoc:AssociationId}"

echo -e "\n========================================="
echo "Verificação concluída. Procure recursos acima."
echo "========================================="
