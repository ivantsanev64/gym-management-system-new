#!/bin/bash
set -e

# Configuration
FTP_HOST="${FTP_HOST:-ftp.yourgym.com}"
FTP_USER="${FTP_USER}"
FTP_PASS="${FTP_PASS}"
FTP_DIR="${FTP_DIR:-/public_html}"
ENVIRONMENT="${1:-staging}"

echo "🚀 Deploying to $ENVIRONMENT via FTP..."

# Install lftp if not available
command -v lftp >/dev/null 2>&1 || { echo "Installing lftp..."; sudo apt-get install -y lftp; }

# Create deployment package
echo "📦 Creating deployment package..."
cd src
zip -r ../deploy.zip . -x "*.git*" -x "*.DS_Store"
cd ..

# Upload via FTP
echo "📤 Uploading files..."
lftp -c "
  open -u $FTP_USER,$FTP_PASS $FTP_HOST
  cd $FTP_DIR
  mirror -R --delete --verbose src/ ./
  bye
"

echo "✅ Deployment complete!"
echo "🌐 Site: https://$ENVIRONMENT.yourgym.com"