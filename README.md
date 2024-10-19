# WasmCloud on ECS Fargate

Infrastructure:

- 1 NATS
  - Public Load Balancer exposing port 4222 ( `wash` access )
- 1 wasmCloud wadm
- 1 wasmCloud worker instance
- 1 wasmCloud ingress instance
  - Public Load Balancer exposing port 80 ( `http` access )

## wash access

```shell
export WASMCLOUD_CTL_HOST="$(terraform output -raw nats_lb)"

wash get inventory
```

## external access

Once `wash` is setup, deploy a sample application:

```shell
wash app deploy ./hello-world-wadm.yaml
```

Access the application:

```shell
export WASMCLOUD_LB="$(terraform output -raw wasmcloud_public_lb)"
curl -i http://$WASMCLOUD_LB
```
