{{/*
Client definition for LogsInstance
*/}}
{{- define "loki.logsInstanceClient" -}}
{{- $isSingleBinary := eq (include "loki.deployment.isSingleBinary" .) "true" -}}
{{- $url := printf "http://%s.%s.svc.%s:3100/loki/api/v1/push" (include "loki.writeFullname" .) .Release.Namespace .Values.global.clusterDomain }}
{{- if $isSingleBinary  }}
  {{- $url = printf "http://%s.%s.svc.%s:3100/loki/api/v1/push" (include "loki.singleBinaryFullname" .) .Release.Namespace .Values.global.clusterDomain }}
{{- else if .Values.gateway.enabled -}}
  {{- $url = printf "http://%s.%s.svc.%s/loki/api/v1/push" (include "loki.gatewayFullname" .) .Release.Namespace .Values.global.clusterDomain }}
{{- end -}}
- url: {{ $url }}
  externalLabels:
    cluster: {{ include "loki.clusterLabel" . }}
  {{- if .Values.enterprise.enabled }}
  basicAuth:
    username:
      name: {{ include "enterprise-logs.selfMonitoringTenantSecret" . }}
      key: username
    password:
      name: {{ include "enterprise-logs.selfMonitoringTenantSecret" . }}
      key: password
  {{- else if .Values.loki.auth_enabled }}
  tenantId: {{ .Values.monitoring.selfMonitoring.tenant.name | quote }}
    {{- if and .Values.monitoring.selfMonitoring.basicAuth.enabled .Values.monitoring.selfMonitoring.basicAuth.username }}
  basicAuth:
    username: {{ .Values.monitoring.selfMonitoring.basicAuth.username | quote }}
    passsword: {{ .Values.monitoring.selfMonitoring.basicAuth.password | quote }}
    {{- else if and .Values.monitoring.selfMonitoring.basicAuth.enabled .Values.monitoring.selfMonitoring.basicAuth.existingSecret }}
  basicAuth:
    username:
      name: {{ .Values.monitoring.selfMonitoring.basicAuth.existingSecret }}
      key: username
    password:
      name: {{ .Values.monitoring.selfMonitoring.basicAuth.existingSecret }}
      key: password
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Convert a recording rule group to yaml
*/}}
{{- define "loki.ruleGroupToYaml" -}}
{{- range . }}
- name: {{ .name }}
  rules:
    {{- toYaml .rules | nindent 4 }}
{{- end }}
{{- end }}

{{/*
GrafanaAgent priority class name
*/}}
{{- define "grafana-agent.priorityClassName" -}}
{{- $pcn := coalesce .Values.global.priorityClassName .Values.monitoring.selfMonitoring.grafanaAgent.priorityClassName -}}
{{- if $pcn }}
priorityClassName: {{ $pcn }}
{{- end }}
{{- end }}
