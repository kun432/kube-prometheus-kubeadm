# kube-prometheus-kubeadm

kubernetes/kubeadm v.1.18用のkube-prometheus
## Prerequisites

```sh
$ go get github.com/google/go-jsonnet/cmd/jsonnet
$ GO111MODULE="on" go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
$ go get github.com/brancz/gojsontoyaml
```

## Usage

```sh
$ git clone https://github.com/kun432/kube-prometheus-kubeadm.git
$ cd kube-prometheus-kubeadm
$ jb install
```

fix base.libsonnet for your environment. Then,

```
$ ./build.sh base.libsonnet
$ kubectl apply -f manifests/setup
$ kubectl apply -f manifests/
```

done!