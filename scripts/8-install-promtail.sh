#!/bin/bash
app="promtail"

if [[ -z $1 ]]
then
  ver="v2.4.2"
else
  ver="$1"
fi

# download application
wget https://github.com/grafana/loki/releases/download/${ver}/promtail-linux-amd64.zip
unzip promtail-linux-amd64.zip

# create directories
mkdir /etc/${app}

# download config file
wget https://raw.githubusercontent.com/grafana/loki/main/clients/cmd/promtail/promtail-local-config.yaml -O /etc/${app}/${app}.yml

# copy binaries
cp ./promtail-linux-amd64 /usr/local/bin/${app}
chmod +x /usr/local/bin/${app}

# setup systemd
cat > /etc/systemd/system/${app}.service << EOF
[Unit]
Description=${app} Service
Wants=network-online.target
After=network.target

[Service]
User=root
Group=root
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

