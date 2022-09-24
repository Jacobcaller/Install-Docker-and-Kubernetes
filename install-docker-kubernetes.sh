#!/bin/bash

echo -n "Please, specify what you want to install.
1 - Docker
2 - Kubernetes
3 - Both
"
read choice

if [ "$choice" = "1" ] || [ "$choice" = "3" ] ; then
    # Installing Docker
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
    rm get-docker.sh
fi

if [ "$choice" = "2" ] || [ "$choice" = "3" ] ; then
    # Installing Kubernetes
    # Source: https://www.cloudsigma.com/how-to-install-and-use-kubernetes-on-ubuntu-20-04/

    # You will start by installing the apt-transport-https package which enables working with http and https in Ubuntu’s repositories.
    # Also, install curl as it will be necessary for the next steps.
    sudo apt install apt-transport-https curl

    # Then, add the Kubernetes signing key to both nodes by executing the command:
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add

    # Next, we add the Kubernetes repository as a package source on both nodes using the following command:
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >> ~/kubernetes.list
    sudo mv ~/kubernetes.list /etc/apt/sources.list.d

    # After that, update the nodes:
    sudo apt update

    # Once the update completes, we will install Kubernetes.
    # This involves installing the various tools that make up Kubernetes: kubeadm, kubelet, kubectl, and kubernetes-cni.
    # These tools are installed on both nodes. We define each tool below:

    # kubelet – an agent that runs on each node and handles communication with the master node to initiate workloads in the container runtime.
    # Enter the following command to install kubelet:
    sudo apt install kubelet

    # kubeadm – part of the Kubernetes project and helps initialize a Kubernetes cluster.
    # Enter the following command to install the kubeadm:
    sudo apt install kubeadm

    # kubectl – the Kubernetes command-line tool that allows you to run commands inside the Kubernetes clusters.
    # Execute the following command to install kubectl:
    sudo apt install kubectl

    # kubernetes-cni – enables networking within the containers ensuring containers can communicate and exchange data.
    # Execute the following command to install:
    sudo apt-get install -y kubernetes-cni

    # Kubernetes fails to function in a system that is using swap memory. Hence, it must be disabled in the master node and all worker nodes.
    # Execute the following command to disable swap memory:
    sudo swapoff -a

    # Comment out string "swapfile" in fstab file if it's present, to disable swap settings
    sed -i "s/swapfile/#swapfile/" /etc/fstab

    # Your nodes must have unique hostnames for easier identification.
    # If you are deploying a cluster with many nodes, you can set it to identify names for your worker nodes such as node-1, node-2, etc.
    # As we had mentioned earlier, we have named our nodes as kubernetes-master and kubernetes-worker.
    # We have set them at the time of creating the server. However, you can adjust or set yours if you had not already done so from the command line.
    echo -n "Please, specify node hostname.
    All node hostnames should be unique.
    If you want to keep the current one, don't type anything and press ENTER."
    read hostname

    if [ -n "$hostname"]; then
        # To adjust the hostname on the master node, run the following command:
        sudo hostnamectl set-hostname $hostname
    fi

    # For the master and worker nodes to correctly see bridged traffic, you should ensure net.bridge.bridge-nf-call-iptables is set to 1 in your config.
    # First, ensure the br_netfilter module is loaded. You can confirm this by issuing the command:
    sudo modprobe br_netfilter

    # Now, you can run this command to set the value to 1:
    sudo sysctl net.bridge.bridge-nf-call-iptables=1

    # Then, execute the following commands to restart and enable Docker on system boot-up:
    sudo systemctl enable docker
    sudo systemctl daemon-reload
    sudo systemctl restart docker

fi
