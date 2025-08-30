FROM ubuntu:latest

VOLUME /homelab
WORKDIR /homelab
COPY . /homelab

ENV GNUPGHOME=/homelab/gnupg
ENV PASSWORD_STORE_DIR=/homelab/password-store
ENV GPG_KEY_NAME="homelab"

RUN <<EOF
#!/bin/bash
apt update -y
apt upgrade -y
apt install -y wget gpg lsb-release mkisofs 7zip python3 pwgen pass
wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
apt update -y
apt install -y packer terraform ansible
EOF

COPY --chmod=700 <<EOF /tmp/bootstrap.sh
#!/bin/bash
mkdir -p "$GNUPGHOME" "$PASSWORD_STORE_DIR"
chmod 700 "$GNUPGHOME"

if ! gpg --list-keys "$GPG_KEY_NAME" > /dev/null 2>&1; then
        gpg --batch --quick-gen-key "$GPG_KEY_NAME"
fi

if [ ! -f "$PASSWORD_STORE_DIR/.gpg-id" ]; then
        echo "$GPG_KEY_NAME" > "$PASSWORD_STORE_DIR/.gpg-id"
        pass init "$GPG_KEY_NAME"
fi

bash
EOF

ENTRYPOINT /tmp/bootstrap.sh
