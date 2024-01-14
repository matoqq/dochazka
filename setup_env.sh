#!/bin/bash

# Remove existing environment
rm -rf .env

# Create a virtual environment in the .env directory
virtualenv .env

# Activate the virtual environment
source .env/bin/activate

# Install dependencies from requirements.txt
pip install -r requirements.txt
