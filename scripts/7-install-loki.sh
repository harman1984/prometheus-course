#!/bin/bash
user="loki"
app="loki"

if [[ -z $1 ]]
then
  ver="v2.4.2"
else
  ver="$1"
fi

# download application
wget https://github.com/grafana/loki/releases/download/${ver}/loki-linux-amd64.zip
unzip loki-linux-amd64.zip

# create directories
mkdir /etc/${app}

# download config file
wget https://raw.githubusercontent.com/grafana/loki/master/cmd/loki/loki-local-config.yaml -O /etc/${app}/${app}.yml

# create user
useradd --no-create-home --shell /bin/false $user

# set ownership
chown -R ${user}:${user} /etc/${app}

# copy binaries
cp loki-linux-amd64 /usr/local/bin/${app}

# set ownership
chown ${user}:${user} /usr/local/bin/${app}

# setup systemd
cat > /etc/systemd/system/${app}.service << EOF
[Unit]
Description=${app} Service
Wants=network-online.target
After=network.target

[Service]
User=${user}
Group=${user}
Type=simple
ExecStart=/usr/local/bin/${app} \
    -config.file=/etc/${app}/${app}.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ${app}.service
systemctl start ${app}.service

# restart service
systemctl restart prometheus.service


echo "(1/2)Setup complete."

