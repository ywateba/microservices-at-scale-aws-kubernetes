

# ### cluster policies

# aws iam create-role \
#   --role-name eksClusterRole \
#   --assume-role-policy-document file://"cluster-trust-policy.json" \
#   --profile udacity


# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEKSClusterPolicy \
#   --role-name eksClusterRole \
#   --profile udacity


# ### Node group policies

# aws iam create-role \
#   --role-name AmazonEKSNodeRole \
#   --assume-role-policy-document file://"node-role-trust-relationship.json" \
#   --profile udacity


# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy \
#   --role-name AmazonEKSNodeRole \
#   --profile udacity

# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly \
#   --role-name AmazonEKSNodeRole \
#   --profile udacity

# aws iam attach-role-policy \
#   --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
#   --role-name AmazonEKSNodeRole \
#   --profile udacity

# aws iam create-policy \
#  --policy-name AmazonEKS_CNI_IPv6_Policy \
#  --policy-document file://vpc-cni-ipv6-policy.json \
#  --profile udacity

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::456619976774:policy/AmazonEKS_CNI_IPv6_Policy \
  --role-name AmazonEKSNodeRole \
  --profile udacity
