```bash
#!/bin/bash
# Update all packages
yum update -y

# Install Apache (httpd)
yum install -y httpd

# Enable and start Apache service
systemctl enable httpd
systemctl start httpd

# Create a simple HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to My Apache Server</title>
    <style>
        body {
            background-color: #0f0f0f;
            color: #00b0c8;
            font-family: Arial, sans-serif;
            text-align: center;
            padding-top: 100px;
        }
        h1 {
            font-size: 3em;
        }
    </style>
</head>
<body>
    <h1>Welcome to My Apache Server on AWS!</h1>
    <p>Successfully deployed using EC2 User Data 🚀</p>
</body>
</html>
EOF

# Restart Apache to ensure everything works
systemctl restart httpd

```