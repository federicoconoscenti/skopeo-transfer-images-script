#!/bin/bash

# Prompt for input for source and destination image and registry information
read -p "Enter source image name and tag (e.g. source-image:tag): " SOURCE_IMAGE
read -p "Enter source registry (e.g. source-registry.com): " SOURCE_REGISTRY
read -p "Enter destination image name and tag (e.g. dest-image:tag): " DEST_IMAGE
read -p "Enter destination registry (e.g. dest-registry.com): " DEST_REGISTRY

# Set authentication information for source and destination registries (if needed)
SOURCE_AUTH=""
DEST_AUTH=""

# Check if Skopeo is installed
if ! command -v skopeo &> /dev/null
then
    echo "Skopeo not found. Installing..."
    sudo yum -y install skopeo  # Replace with the appropriate package manager for your system
fi

# Pull the source image from the source registry
docker pull "${SOURCE_REGISTRY}/${SOURCE_IMAGE}"

# Tag the source image with the destination registry and image name
docker tag "${SOURCE_REGISTRY}/${SOURCE_IMAGE}" "${DEST_REGISTRY}/${DEST_IMAGE}"

# Push the tagged image to the destination registry
docker push "${DEST_REGISTRY}/${DEST_IMAGE}"

# Remove the local copy of the source image
docker rmi "${SOURCE_REGISTRY}/${SOURCE_IMAGE}"

# Remove the local copy of the destination image
docker rmi "${DEST_REGISTRY}/${DEST_IMAGE}"

# Use Skopeo to copy the image from the source registry to the destination registry
skopeo copy "docker://${SOURCE_REGISTRY}/${SOURCE_IMAGE}" "docker://${DEST_REGISTRY}/${DEST_IMAGE}" --src-creds="${SOURCE_AUTH}" --dest-creds="${DEST_AUTH}"