# Guide Ansible - De Zéro à Héros

## Pourquoi Ansible ?

Terraform crée notre infra, mais après faut la configurer genre installer des truc etc... Terraform peut faire un peu de config, mais c'est pas son truc. Pour tout ce qui est configuration système, Ansible écrase tout.
Apres la doc de ansible est claire et precis pour plus de profondeur
**Les gros avantages :**

- Installation ultra simple
- Fonctionne par SSH (pas d'agent à installer partout)
- Tourne nativement sur Linux/macOS
- Sur Windows, passe par WSL

---

## Commandes AD-HOC (pour tester vite fait)

Les commandes ad-hoc c'est pour faire des trucs rapides sans écrire de playbook.

### L'inventaire

Fichier par défaut : `/etc/ansible/hosts`

Exemple minimal :

```ini
node1  # un seul host

[webservers]  # un groupe d'hosts
node2
node3

[databases]
db1
db2
```

**Tester la connectivité :**

```bash
ansible all -m ping
ansible webservers -m ping
```

**Utiliser un inventaire custom :**

```bash
ansible all -i /path/to/inventory -m ping
```

### Modules ad-hoc

Installer un paquet :

```bash
ansible node2 -m yum -a "name=nginx state=present"
```

Redémarrer un service :

```bash
ansible webservers -m service -a "name=nginx state=restarted"
```

Créer un fichier :

```bash
ansible all -m file -a "path=/tmp/test state=touch"
```

---

## Les Playbooks (le vrai truc)

Les commandes ad-hoc c'est cool pour tester, mais pour automatiser sérieusement, faut des playbooks.

**Règle de base :** Tous les fichiers Ansible commencent par `---`

### Exemple simple

```yaml
---
- hosts: webservers
  become: true  # équivalent de sudo
  tasks:
    - name: Installer Apache et PHP
      yum:
        name: 
          - httpd
          - php
          - php-common
          - php-cli
        state: present

    - name: Démarrer Apache
      service:
        name: httpd
        state: started
        enabled: yes

    - name: Créer le dossier du site
      file:
        state: directory
        path: "/var/www/html/mon_site"
        mode: 0755
        owner: apache
        group: apache
```

**Lancer le playbook :**

```bash
ansible-playbook install_apache.yml
```

---

## Les Variables (pour pas se répéter)

### 1. Variables dans le playbook

```yaml
---
- hosts: webservers
  become: true
  vars:
    app_user: webapp
    install_dir: /opt/myapp
    packages:
      - nginx
      - postgresql

  tasks:
    - name: Créer l'utilisateur
      user:
        name: "{{ app_user }}"
        state: present

    - name: Installer les paquets
      yum:
        name: "{{ packages }}"
        state: present
```

### 2. Variables dans des fichiers séparés

Crée un fichier `vars/main.yml` :

```yaml
---
app_user: webapp
install_dir: /opt/myapp
```

Puis dans ton playbook :

```yaml
---
- hosts: webservers
  vars_files:
    - vars/main.yml
  tasks:
    # utilise {{ app_user }} et {{ install_dir }}
```

### 3. Extra-vars (priorité maximale)

```bash
ansible-playbook playbook.yml --extra-vars "app_user=admin install_dir=/home/admin/app"
```

**Ordre de priorité (du moins au plus prioritaire) :**

1. Rôle defaults
2. Inventaire vars
3. Playbook vars
4. Vars files
5. **Extra vars** (gagne toujours)

### 4. Les Facts (infos auto-récupérées)

Ansible récupère automatiquement plein d'infos sur tes machines :

```bash
ansible node2 -m setup
```

Tu récupères un gros JSON avec :

- `ansible_hostname` : nom de la machine
- `ansible_os_family` : RedHat, Debian, etc.
- `ansible_architecture` : x86_64, arm64...
- `ansible_default_ipv4.address` : IP de la machine
- `ansible_distribution` : CentOS, Ubuntu, Fedora...
- `ansible_memtotal_mb` : RAM totale
- Et des tonnes d'autres trucs

**Utilisation dans un playbook :**

```yaml
- name: Installer un paquet selon l'OS
  package:
    name: "{{ 'httpd' if ansible_os_family == 'RedHat' else 'apache2' }}"
    state: present
```

---

## Les Templates Jinja2 (configs dynamiques)

Les templates te permettent de générer des fichiers avec des variables dedans. Extension : `.j2`

### Exemple : `index.html.j2`

```jinja2
<!DOCTYPE html>
<html>
<head>
    <title>Serveur {{ ansible_hostname }}</title>
</head>
<body>
    <h1>Bienvenue sur {{ ansible_hostname }}</h1>
    <p>Architecture : {{ ansible_architecture }}</p>
    <p>OS : {{ ansible_distribution }} {{ ansible_distribution_version }}</p>
    <p>IP : {{ ansible_default_ipv4.address }}</p>
</body>
</html>
```

### Déployer le template

```yaml
- name: Générer la page d'accueil
  template:
    src: templates/index.html.j2
    dest: /var/www/html/index.html
    owner: apache
    group: apache
    mode: 0644
```

### Template de config plus complexe

`nginx.conf.j2` :

```jinja2
user {{ nginx_user }};
worker_processes {{ ansible_processor_vcpus }};

server {
    listen 80;
    server_name {{ server_name }};
    
    {% for location in locations %}
    location {{ location.path }} {
        proxy_pass {{ location.backend }};
    }
    {% endfor %}
}
```

---

## Les Rôles (pour structurer proprement)

Les rôles permettent d'organiser ton code. Ça devient vite indispensable sur de vrais projets.

### Structure d'un rôle

```
roles/
└── webserver/
    ├── tasks/
    │   └── main.yml          # Tâches principales
    ├── handlers/
    │   └── main.yml          # Actions déclenchées (restart services)
    ├── templates/
    │   └── nginx.conf.j2     # Templates Jinja2
    ├── files/
    │   └── logo.png          # Fichiers statiques qu'on vx copier (on evite les binaires)
    ├── vars/
    │   └── main.yml          # Variables (priorité haute)
    ├── defaults/
    │   └── main.yml          # Variables par défaut (priorité basse)
    └── meta/
        └── main.yml          # Métadonnées et dépendances
```

### Créer un rôle

```bash
ansible-galaxy init webserver
```

### Utiliser un rôle dans un playbook

```yaml
---
- hosts: webservers
  become: true
  roles:
    - webserver
    - firewall
    - monitoring
```

### Ansible Galaxy (rôles communautaires)

Chercher un rôle : qu'

```bash
ansible-galaxy search nginx
```

Installer un rôle :

```bash
ansible-galaxy install geerlingguy.nginx
```

Utiliser le rôle installé :

```yaml
---
- hosts: webservers
  roles:
    - geerlingguy.nginx
```

## Ansible Vault (protéger les secrets)

Vault sert à chiffrer les données sensibles : mots de passe, clés SSH, tokens...

### Chiffrer un fichier complet

```bash
ansible-vault encrypt secrets.yml
```

### Déchiffrer

```bash
ansible-vault decrypt secrets.yml
```

### Modifier un fichier chiffré (sans le déchiffrer)

```bash
ansible-vault edit secrets.yml
```

### Chiffrer juste une variable

```bash
ansible-vault encrypt_string 'mon_super_password' --name 'db_password'
```

Résultat à mettre dans ton playbook :

```yaml
db_password: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          653030313...
```

### Lancer un playbook avec des secrets

```bash
ansible-playbook playbook.yml --ask-vault-pass
```

Ou avec un fichier de mot de passe :

```bash
ansible-playbook playbook.yml --vault-password-file ~/.vault_pass
```

---

## AWX / Ansible Tower (l'interface web)

**Ansible Tower** = version payante de Red Hat avec support  
**AWX** = version open source gratuite

### Pourquoi AWX ?

- Interface web pour lancer des playbooks (plus besoin de CLI)
- **Gestion centralisée** : inventaires, credentials, projets
- **Planification** : lance des playbooks en cron
- **Logs et historique** de toutes les exécutions
- **RBAC** : gère les permissions par équipe/user
- **API REST** : automatise tout depuis d'autres outils

### Concepts clés dans AWX

1. **Projects** : ton repo Git avec tes playbooks
2. **Inventories** : tes machines cibles
3. **Credentials** : SSH keys, tokens, passwords (chiffrés)
4. **Job Templates** : "lance CE playbook sur CET inventaire avec CES credentials"
5. **Workflows** : enchaîne plusieurs jobs

### Workflow typique

1. Tu push tes playbooks dans Git
2. Tu crées un Project dans AWX pointant vers ton repo
3. Tu crées un Job Template
4. Tu cliques sur dans AWX
5. AWX pull ton code, lance le playbook, et te montre les logs live

**Important :** On écris JAMAIS les playbooks dans AWX. C'est juste un orchestrateur.

## Points clés à retenir

**Ansible = agentless** (juste SSH)  
**YAML strict** : l'indentation c'est la vie  
**Structure propre** : inventaires → playbooks → rôles  
**Facts = auto-magic** : Ansible sait tout sur tes machines  
**Extra-vars = priorité max**  
**Templates Jinja2** = configs dynamiques  
**Vault = secrets protégés**  
**AWX = interface web** pour orchestrer (mais tu codes toujours en local)  
**Git = source of truth** : tout doit être versionné