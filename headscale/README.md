# Headscale

Builds the `ybbapp/headscale-edition` source repository into a multi-architecture image.

The GitHub Actions workflow accepts an upstream tag through `workflow_dispatch`.
It defaults to `v0.29.3-home` and publishes:

```text
ghcr.io/ybbapp/headscale:v0.29.3-home
```
