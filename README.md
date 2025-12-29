Projet de mise en place d'un infra complete stack:
- Ansible
- Terraform
- Kubernetes (Eks)
- Registry: Aws ECR
- DNS: Router53
- ArgoCd
- Prometheus, Grafana
- Jenkins
- Trivy
- SonarQube

L'application en soit est un simple todo react mais le but ici c'est de build un infra solide et scalable.
## Structure du projet
```
.
├── README.md
├── learning/
│   ├── terraform.md
│   └── ansible.md
└── iac/
    ├── terraform/
    └── ansible/
```

## Contenu

### Documentation (`learning/`)

- **terraform.md** : Guide et notes sur Terraform
- **ansible.md** : Guide et notes sur Ansible

### Code (`iac/`)

- **terraform/** : Configuration infrastructure Terraform
- **ansible/** : Playbooks et rôles Ansible

## Utilisation

### Terraform
```bash
cd iac/terraform
terraform init
terraform plan
terraform apply
```

### Ansible
```bash
cd iac/ansible
ansible-playbook playbook/site.yml
```

## Prérequis

- Terraform >= 1.0
- Ansible >= 2.9
- Compte cloud configuré (AWS/Azure/GCP selon le code)

## Notes

Consulter les fichiers dans `learning/` pour comprendre les concepts et bonnes pratiques.
