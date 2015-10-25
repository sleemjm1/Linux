#!/bin/bash

# Alias test script

username=$1

echo "alias off='systemctl poweroff -i'" >> /home/$username/.bashrc
