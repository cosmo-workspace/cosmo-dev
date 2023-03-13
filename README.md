# All-in-one code-server image for cosmo development

This code-server image allows you to quickly build the development environment for COSMO development.

Simply launch this code-server image and clone the [cosmo repository](https://github.com/cosmo-workspace/cosmo), then you can develop, test and build COSMO projects.

# Quickstart

```sh
helm repo add cosmo https://cosmo-workspace.github.io/charts

helm upgrade --install -n cosmo-dev --create-namespace code-server cosmo/dev-code-server --set service.type=LoadBalancer
```

You can change install options for example using Ingress on your cluster.
Please see [`values.yaml`](https://github.com/cosmo-workspace/charts/blob/main/charts/dev-code-server/values.yamls) for all of the available install options.