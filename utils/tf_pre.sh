#!/bin/bash

# !! Run this command from project root !!

cd tf/

echo "Attempting to format and initialise terraform..."

terraform fmt
echo "Format step complete."

terraform init
echo "Initialise step finished."

# Go back to project root
cd ../
