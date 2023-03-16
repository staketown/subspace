#!/bin/bash

source <(curl -s https://raw.githubusercontent.com/R1M-NODES/utils/master/common.sh)

printLogo

sudo apt update && sudo apt install curl ocl-icd-opencl-dev libopencl-clang-dev libgomp1 -y
cd $HOME
wget -O subspace-cli https://github.com/subspace/subspace-cli/releases/download/v0.1.9-alpha/subspace-cli-Ubuntu-x86_64-v0.1.9-alpha
sudo chmod +x subspace-cli
sudo mv subspace-cli /usr/local/bin/
sudo rm -rf $HOME/.config/subspace-cli

echo "alias subspace-cli='/usr/local/bin/subspace-cli'" >> $HOME/.bashrc
touch $HOME/.bash_profile && source $HOME/.bashrc && sleep 1

subspace-cli init

source $HOME/.bash_profile
sleep 1

sudo tee /etc/systemd/system/subspaced.service > /dev/null << EOF
[Unit]
Description=Subspace Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which subspace-cli) farm --verbose
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable subspaced
sudo systemctl restart subspaced

if [[ `service subspaced status | grep active` =~ "running" ]]; then
    printGreen "Your node has been installed successfully"
    printGreen "Check your node status: journalctl -u subspaced -f -o cat"
  else
    printGreen "Your node hasn't been installed. Re-install it!"
fi