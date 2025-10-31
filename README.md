# ansible-vault-editor

> Script di installazione dell'utility per la creazione/modifica dei file cifrati con [Ansible Vault](https://docs.ansible.com/ansible/latest/vault_guide/index.html).

---

### 📦 Installazione

Lanciare la procedura con:

```bash
sudo apt update
sudo apt install -y curl ansible gpg
bash <(curl -fsSL https://raw.githubusercontent.com/paspiz85/ansible-vault-editor/main/install.sh)
```

**ATTENZIONE**: su Windows va installato esclusivamente da WSL quindi aprire una powershell in modalità amministrativa:

```cmd
wsl --install -d Debian
sudo apt update
sudo apt install -y curl ansible gpg
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
tee nano ~/.gnupg/gpg.conf > /dev/null <<EOF
use-agent
pinentry-mode loopback
EOF
tee nano ~/.gnupg/gpg-agent.conf > /dev/null <<EOF
allow-loopback-pinentry
EOF
gpgconf --kill gpg-agent
bash <(curl -fsSL https://raw.githubusercontent.com/paspiz85/ansible-vault-editor/main/install.sh)
ansible-vault-editor -e nano
```

---

### ▶️ Esecuzione

Per prima cosa bisogna scaricare la chiave di un host con:

```bash
ssh pi@peppe.local "sudo cat /etc/ansible-gitops/ansible-vault.key" | ansible-vault-editor -c peppe
```

Per creare/modificare un file di secret:

```bash
ansible-vault-editor -e "subl -w"
ansible-vault-editor peppe inventory/prod/host_vars/peppe/secrets.yml
```

**ATTENZIONE**: su Windows va utilizzato esclusivamente da WSL quindi aprire una powershell:

```cmd
wsl -d Debian
ssh pi@peppe.local "sudo cat /etc/ansible-gitops/ansible-vault.key" | ansible-vault-editor -c peppe
ansible-vault-editor peppe inventory/prod/host_vars/peppe/secrets.yml
```

Inoltre si consiglia di usare sempre nano poichè gli editor di Windows non permettono di accedere allo stesso file-system di WSL
