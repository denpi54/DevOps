# DevOps Diploma Project - Infrastructure as Code

Содержит:
- Terraform конфигурации для развёртывания 3 ВМ (k8s master, k8s worker, srv) в Yandex.Cloud (пример)
- Ansible плейбуки и роли для пост-установки (Docker, kubeadm, srv stack)
- Helm chart для простого Django приложения + Postgres
- Docker Compose для мониторинга (Prometheus, Alertmanager, Grafana, Blackbox) и Graylog
- Prometheus rules, Fluent Bit манифесты и пример CI (GitLab CI)

> **Внимание:** нигде в репозитории нет секретов. Перед применением заполните соответствующие переменные / секреты (Terraform tfvars, Ansible Vault, CI variables).

## Быстрая инструкция
1. Заполнить `iac/terraform/yandex/terraform.tfvars` (token, cloud_id, folder_id, ssh_pub_key).
2. `cd iac/terraform/yandex && terraform init && terraform apply`
3. Взять IP-адреса из `terraform output` и положить в `ansible/inventories/prod.ini`
4. Запустить Ansible:
   ```bash
   ansible-playbook -i ansible/inventories/prod.ini ansible/playbooks/01-bootstrap.yml
   ansible-playbook -i ansible/inventories/prod.ini ansible/playbooks/02-k8s.yml
   ansible-playbook -i ansible/inventories/prod.ini ansible/playbooks/03-srv.yml
   ```
5. В k8s установить ingress-nginx, затем применить `k8s/logging/fluent-bit/*.yaml`
6. Настроить CI (GitLab/GitHub) с переменными: registry credentials, KUBECONFIG (base64), ingress host и т.д.
