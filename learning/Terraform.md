Ce document reprend tout ce que tu as appris sur Terraform, mais de manière structurée, propre et compréhensible, sans perdre les explications essentielles. Mais n'empeche que ce doc ne couvre pas tout c'est faut checker la doc de terraform.
# 1. Comprendre Terraform

Terraform est un outil d'Infrastructure as Code (IaC). L'idée est simple : tu écris du code pour décrire ton infrastructure, puis Terraform s'occupe de la créer et de la maintenir.

Il n'y a rien de magique : Terraform a besoin d'un **provider**, qui est le pont entre ton code et la plateforme cloud (AWS ici). Sans provider, Terraform ne sait pas où créer tes ressources.

Pour AWS, il faut :
- Installer AWS CLI 
- Configurer un utilisateur IAM en local (`aws configure`)
- Ne jamais utiliser le compte root

Terraform utilise ces identifiants pour agir sur AWS.

Exemple de provider :

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}
```

---

# 2. Créer une instance EC2

On n'as pas besoin de tout connaître par cœur. Dès que l'on veux une ressource, on recherches sur google:

```
aws terraform resource <nom>
```

Exemple EC2 :

```terraform
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
    Name = "HelloWorld"
  }
}
```

Pour récupérer l'AMI Ubuntu automatiquement :

```terraform
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
```

---

# 3. Commandes Terraform essentielles

- `terraform init` → initialise le projet et télécharge les providers
    
- `terraform plan` → montre ce qui va être créé/modifié/détruit
    
- `terraform apply` → applique les changements
    
- `terraform destroy` → supprime les ressources
    
- `terraform state list` → affiche les ressources connues du state
    

Terraform garde un fichier `terraform.tfstate` qui contient l'état de ton infra pour éviter les recréations inutiles.

---

# 4. Travailler à plusieurs – Backend S3 + DynamoDB

Si 10 personnes gèrent la même infra, c'est ingérable avec un `.tfstate` local.

Solution : backend distant.

- Le state est stocké dans un bucket S3
    
- Le verrouillage (lock) est géré par DynamoDB pour éviter deux `apply` en même temps
    

Exemple :

```terraform
terraform {
  backend "s3" {
    bucket       = "myS3bucket"
    key          = "PREPROD/terraform.tfstate"
    region       = "eu-west-1"
    dynamodb_table = "terraform-lock"
  }
}
```

Le bucket et la table DynamoDB doivent être créés manuellement.

---

# 5. VPC, Subnets et réseaux

AWS crée par défaut un VPC et des subnets si tu n'en définis pas. Mais dès que tu fais de l'architecture propre, tu dois les définir toi-même.

### VPC :

```terraform
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}
```

### Subnet :

```terraform
resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Main"
  }
}
```

### Taille des subnets (Rappel) :

|Masque|IP totales|IP utilisables AWS|Usage|
|---|---|---|---|
|/16|65 536|65 531|Trop gros pour un subnet|
|/20|4 096|4 091|Plusieurs services|
|/24|256|251|Standard (web/app/db)|
|/28|16|11|Tests ou micro services|

---

# 6. Attacher une interface réseau (ENI) à un EC2

```terraform
resource "aws_network_interface" "foo" {
  subnet_id       = aws_subnet.main.id
  private_ips     = ["10.0.1.5"]
  security_groups = [aws_security_group.web.id]
}

resource "aws_instance" "foo" {
  ami           = "ami-005e54dee72cc1d00"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }
}
```

---

# 7. Variables, .tfvars et bonnes pratiques

Terraform a trois éléments importants :

### 1. `variables.tf`

Déclare les variables.

```terraform
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
```

### 2. Utilisation dans les fichiers

```terraform
instance_type = var.instance_type
```

### 3. `terraform.tfvars`

Contient les valeurs réelles.

```tfvars
instance_type = "t3.micro"
```

Pas de mot-clé `variable`. C'est juste clé = valeur.

### 4. `terraform.tfvars.example`

Documente les variables pour la team.

### Règle générale

- `variables.tf` → déclaration
    
- `terraform.tfvars` → valeurs sensibles / que tu veux changer
    
- `*.tf` → utilise `var.<nom>`
    

Si une variable n’a pas de valeur, Terraform te la demande en CLI.

---

# 8. Meta-arguments : count, index, for_each

Créer plusieurs ressources identiques :

```terraform
resource "aws_instance" "server" {
  count = 4

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index}"
  }
}
```

---

# 9. IP dynamiques pour plusieurs instances

```terraform
resource "aws_instance" "foo" {
  count         = 10
  ami           = "ami-005e54dee72cc1d00"
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo[count.index].id
    device_index         = 0
  }
}

resource "aws_network_interface" "foo" {
  count           = 10
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = [cidrhost(aws_subnet.my_subnet.cidr_block, count.index + 10)]
  security_groups = [aws_security_group.sg.id]
}
```

---

# 10. Exécuter des commandes dans une instance EC2

Même si c'est mieux avec Ansible, Terraform permet des scripts via `provisioners`.

### Exemple : exécuter un script au boot

```terraform
resource "aws_instance" "example" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  user_data = <<EOF
#!/bin/bash
apt update -y
apt install nginx -y
systemctl start nginx
EOF
}
```

### Provisioner remote-exec (connexion SSH)

```terraform
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install docker.io -y"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}
```