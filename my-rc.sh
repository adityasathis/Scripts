#!/bin/bash
# my-rc.sh
# Author	: Aditya Sathish
# Date  	: October 12th 2023
# Description	: A list of functions which need to be run during initialization of my user shell

add_private_keys() {
  if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
  fi

  # Add SSH keys with .key extension from ~/.ssh directory
  for keyfile in ~/.ssh/private_keys/*.priv; do
    if [ -f "$keyfile" ]; then
      ssh-add "$keyfile"
    fi
  done
}

create_key() {
  if [ -z "$1" ]; then
    echo "Error: Private key name not provided. Please provide a valid name as an argument."
    return 1
  fi

  private_key_name="$1.priv"
  public_key_name="$1.pub"
  private_keys_dir="$HOME/.ssh/private_keys"
  public_keys_dir="$HOME/.ssh/public_keys"

  # Check if the private key name already exists in private_keys
  if [ -f "$private_keys_dir/$private_key_name" ]; then
    echo "Error: Private key with the same name $1 already exists in ~/.ssh/private_keys."
    return 1
  fi

  # Check if the public key name already exists in public_keys
  if [ -f "$public_keys_dir/$public_key_name" ]; then
    echo "Error: Public key with the same name $1 already exists in ~/.ssh/public_keys."
    return 1
  fi

  ssh-keygen -t ed25519 -f "$private_key_name"
  mv "${private_key_name}.pub" "${public_key_name}"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to generate the SSH key pair."
    return 1
  fi

  # Move the public key to ~/.ssh/public_keys
  mv "$public_key_name" "$HOME/.ssh/public_keys/"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to move the public key to ~/.ssh/public_keys."
    return 1
  fi

  # Move the private key to ~/.ssh/private_keys
  mv "$private_key_name" "$HOME/.ssh/private_keys/"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to move the private key to ~/.ssh/private_keys."
    return 1
  fi

  echo "SSH key pair generated and moved to ~/.ssh/public_keys and ~/.ssh/private_keys."
}

add_private_keys
