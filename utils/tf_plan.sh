#!/bin/bash

# !! Run this command from project root !!

# Format and init tf
sh utils/tf_pre.sh

cd tf/

terraform plan -var-file=tf/.auto.tfvars

# Go back to project root
cd ../
