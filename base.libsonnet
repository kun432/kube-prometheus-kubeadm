local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet') + 
  (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  {
    _config+:: {
      namespace: 'monitoring',
      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'http://proxy.internal/grafana',
            },
          },
        },
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          externalUrl: 'http://proxy.internal/prometheus',
        },
      },
    },
    alertmanager+:: {
      alertmanager+: {
        spec+: {
          externalUrl: 'http://proxy.internal/alertmanager',
        },
      },
    },
    ingress+:: {
      'prometheus-k8s': {
        apiVersion: 'networking.k8s.io/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: $.prometheus.prometheus.metadata.name,
          namespace: $.prometheus.prometheus.metadata.namespace,
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
          },
        },
        spec: {
          rules: [{
            http: {
              paths: [{
                path: '/prometheus(/|$)(.*)',
                backend: {
                  serviceName: $.prometheus.service.metadata.name,
                  servicePort: 'web',
                },
              }],
            },
          }],
        },
      },
      'alertmanager-main': {
        apiVersion: 'networking.k8s.io/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: $.alertmanager.alertmanager.metadata.name,
          namespace: $.alertmanager.alertmanager.metadata.namespace,
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
          },
        },
        spec: {
          rules: [{
            http: {
              paths: [{
                path: '/alertmanager(/|$)(.*)',
                backend: {
                  serviceName: $.alertmanager.service.metadata.name,
                  servicePort: 'web',
                },
              }],
            },
          }],
        },
      },
      'grafana': {
        apiVersion: 'networking.k8s.io/v1beta1',
        kind: 'Ingress',
        metadata: {
          name: 'grafana',
          namespace: 'monitoring',
          annotations: {
            'kubernetes.io/ingress.class': 'nginx',
            'nginx.ingress.kubernetes.io/rewrite-target': '/$2',
          },
        },
        spec: {
          rules: [{
            http: {
              paths: [{
                path: '/grafana(/|$)(.*)',
                backend: {
                  serviceName: 'grafana',
                  servicePort: 'http',
                },
              }],
            },
          }],
        },
      },
    },
  };

{ ['setup/0namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{
  ['setup/prometheus-operator-' + name]: kp.prometheusOperator[name]
  for name in std.filter((function(name) name != 'serviceMonitor'), std.objectFields(kp.prometheusOperator))
} +
// serviceMonitor is separated so that it can be created after the CRDs are ready
{ 'prometheus-operator-serviceMonitor': kp.prometheusOperator.serviceMonitor } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ ['ingress-' + name]: kp.ingress[name] for name in std.objectFields(kp.ingress) }
