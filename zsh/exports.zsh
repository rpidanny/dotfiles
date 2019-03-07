export LC_ALL=en_US.UTF-8
export PATH=/usr/local/cuda-9.0/bin${PATH:+:${PATH}}
# export PATH=/usr/local/cuda-8.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH='/usr/local/cuda/lib64'
export CUDA_HOME=/usr/local/cuda
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME
export GOBIN=$GOPATH/bin
export PATH=$HOME/workspace/rnd/hyperledger/fabric-samples/bin:$PATH
export TFHUB_CACHE_DIR=$HOME/.tfhub_modules

if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi

# For local exports
[ -f '.exports.local' ] && source '.exports.local'