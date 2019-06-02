{{/* vim: set filetype=mustache: */}}
default: &default
  adapter: postgresql
  host: "{{ template "gorgeous-code-assessment.postgresql.fullname" . }}"
  port: {{ int .Values.postgresql.service.port }}
  endcoding: utf8
  pool: 5
  timeout: 5000
  database: {{ .Values.postgresql.global.postgresql.postgresqlDatabase }}
  username: {{ .Values.postgresql.global.postgresql.postgresqlUsername }}
  password: <%= ENV['POSTGRES_PASSWORD'] %>

development:
  <<: *default
  database: gorgeous-code_development

test:
  <<: *default
  database: gorgeous-code_test

production:
  <<: *default
  database: gorgeous-code_production
