#!/bin/bash
set -e
LOG_FILE="install.log"

echo "=== Start installation ===" | tee -a $LOG_FILE

# Python >=3.9
if ! command -v python3 &> /dev/null || [[ $(python3 -V | cut -d' ' -f2) < "3.9" ]]; then
    echo "Installing Python 3.9+" | tee -a $LOG_FILE
    sudo apt update
    sudo apt install -y python3 python3-pip
else
    echo "Python OK: $(python3 --version)" | tee -a $LOG_FILE
fi

# pip
pip3 install --upgrade pip | tee -a $LOG_FILE

# Python libs
for pkg in torch torchvision pillow django; do
    if ! python3 -c "import $pkg" &> /dev/null; then
        echo "Installing $pkg" | tee -a $LOG_FILE
        pip3 install $pkg | tee -a $LOG_FILE
    else
        echo "$pkg already installed" | tee -a $LOG_FILE
    fi
done

echo "=== Installation finished ===" | tee -a $LOG_FILE
