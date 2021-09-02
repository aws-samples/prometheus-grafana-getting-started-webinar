#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -e 

cluster_name='amp-demo'
region="${AWS_REGION:=eu-west-1}"
ssh_key="${SSH_KEY:=eu-west-1-default}"
spot_type="${NODE_SIZE:=m6g.medium}"
account_id=$(aws sts get-caller-identity --query "Account" --output text)

echo "Creating EKS Cluster"
eksctl create cluster --name ${cluster_name} \
    --auto-kubeconfig \
    --full-ecr-access \
    --region ${region} \
    --without-nodegroup \
    --version 1.20

# In order to run Graviton 2 instances we need to make sure we are up to date with aws-node, coredns, kube-proxy
echo "Upgrading cluster components"
eksctl utils update-aws-node --cluster ${cluster_name} --approve
eksctl utils update-coredns --cluster ${cluster_name} --approve
eksctl utils update-kube-proxy --cluster ${cluster_name} --approve

echo "Launching node group"
eksctl create nodegroup --name spot-group \
    --ssh-access \
    --ssh-public-key ${ssh_key} \
    --node-type  ${spot_type} \
    --managed \
    --spot \
    --nodes-min 3 \
    --nodes-max 5 \
    --cluster ${cluster_name}
