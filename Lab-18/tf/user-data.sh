#!/bin/bash

# User data script for EC2 instances
# This script installs and configures Apache web server

INSTANCE_NAME="${instance_name}"

# Update system
yum update -y

# Install Apache web server
yum install -y httpd

# Get instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# Create custom index page
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>K21 EC2 Instance INSTANCE_NAME_VAR</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        
        .container {
            background: rgba(255, 255, 255, 0.95);
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            width: 100%;
            backdrop-filter: blur(10px);
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            color: #333;
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
            color: #667eea;
        }
        
        .instance-badge {
            display: inline-block;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 10px 30px;
            border-radius: 50px;
            font-size: 1.2em;
            font-weight: bold;
            margin: 10px 0;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .info-card {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            padding: 20px;
            border-radius: 10px;
            border-left: 4px solid #667eea;
        }
        
        .info-card .label {
            font-weight: bold;
            color: #555;
            font-size: 0.9em;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 8px;
        }
        
        .info-card .value {
            color: #333;
            font-size: 1.1em;
            word-break: break-all;
        }
        
        .status-message {
            background: linear-gradient(135deg, #84fab0 0%, #8fd3f4 100%);
            padding: 20px;
            border-radius: 10px;
            text-align: center;
            margin: 20px 0;
            color: #333;
            font-size: 1.1em;
        }
        
        .footer {
            text-align: center;
            margin-top: 30px;
            padding-top: 20px;
            border-top: 2px solid #e0e0e0;
            color: #666;
        }
        
        .emoji {
            font-size: 1.5em;
        }
        
        @media (max-width: 600px) {
            .header h1 {
                font-size: 1.8em;
            }
            .container {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1><span class="emoji">🚀</span> K21 Load Balancer Lab</h1>
            <div class="instance-badge">Instance INSTANCE_NAME_VAR</div>
        </div>
        
        <div class="status-message">
            <span class="emoji">✅</span> This request was served by <strong>Instance INSTANCE_NAME_VAR</strong>
        </div>
        
        <div class="info-grid">
            <div class="info-card">
                <div class="label">Instance ID</div>
                <div class="value">INSTANCE_ID_VAR</div>
            </div>
            
            <div class="info-card">
                <div class="label">Availability Zone</div>
                <div class="value">AVAILABILITY_ZONE_VAR</div>
            </div>
            
            <div class="info-card">
                <div class="label">Private IP</div>
                <div class="value">PRIVATE_IP_VAR</div>
            </div>
            
            <div class="info-card">
                <div class="label">Public IP</div>
                <div class="value">PUBLIC_IP_VAR</div>
            </div>
        </div>
        
        <div class="footer">
            <p><span class="emoji">🔄</span> Refresh the page to see load balancing in action!</p>
            <p style="margin-top: 10px; font-size: 0.9em;">AWS Application Load Balancer Demo</p>
        </div>
    </div>
</body>
</html>
HTML

# Replace placeholders with actual values
sed -i "s/INSTANCE_NAME_VAR/$INSTANCE_NAME/g" /var/www/html/index.html
sed -i "s/INSTANCE_ID_VAR/$INSTANCE_ID/g" /var/www/html/index.html
sed -i "s/AVAILABILITY_ZONE_VAR/$AVAILABILITY_ZONE/g" /var/www/html/index.html
sed -i "s/PRIVATE_IP_VAR/$PRIVATE_IP/g" /var/www/html/index.html
sed -i "s/PUBLIC_IP_VAR/$PUBLIC_IP/g" /var/www/html/index.html

# Create health check endpoint
cat > /var/www/html/health.html <<'HEALTH'
<!DOCTYPE html>
<html>
<head>
    <title>Health Check</title>
</head>
<body>
    <h1>OK</h1>
    <p>Instance is healthy</p>
</body>
</html>
HEALTH

# Create a simple API endpoint for testing
cat > /var/www/html/api.html <<'API'
<!DOCTYPE html>
<html>
<head>
    <title>API Response</title>
</head>
<body>
    <pre>
{
  "status": "healthy",
  "instance_id": "INSTANCE_ID_VAR",
  "availability_zone": "AVAILABILITY_ZONE_VAR",
  "instance_name": "INSTANCE_NAME_VAR",
  "timestamp": "TIMESTAMP_VAR"
}
    </pre>
</body>
</html>
API

# Replace placeholders in API endpoint
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i "s/INSTANCE_NAME_VAR/$INSTANCE_NAME/g" /var/www/html/api.html
sed -i "s/INSTANCE_ID_VAR/$INSTANCE_ID/g" /var/www/html/api.html
sed -i "s/AVAILABILITY_ZONE_VAR/$AVAILABILITY_ZONE/g" /var/www/html/api.html
sed -i "s/TIMESTAMP_VAR/$TIMESTAMP/g" /var/www/html/api.html

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Configure firewall (if enabled)
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-service=http
    firewall-cmd --reload
fi

# Log completion
echo "User data script completed successfully for Instance $INSTANCE_NAME" >> /var/log/user-data.log
echo "Timestamp: $(date)" >> /var/log/user-data.log
