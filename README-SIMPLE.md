# MarkD - Simple Deployment Guide

A simple way to deploy MarkD without Docker or complex configuration.

## 🚀 Quick Start (5 minutes)

### Prerequisites
- **Python 3.9+**
- **Node.js 18+**
- **MySQL/MariaDB 8.0+**
- **git**

### Installation

#### 1. Clone the repository
```bash
git clone https://github.com/xavdp-pro/markd.git
cd markd
```

#### 2. Database Setup
```bash
# Create database and user (as root)
mysql -u root -p

CREATE DATABASE markd CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'markd_user'@'localhost' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON markd.* TO 'markd_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# Import database schema
mysql -u markd_user -p markd < database/install.sql
```

#### 3. Configure Backend
```bash
cd backend
cp .env.example .env

# Edit .env with your database settings
nano .env
```

**Required settings in `backend/.env`:**
```ini
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=markd
MYSQL_USER=markd_user
MYSQL_PASSWORD=your_secure_password

# Generate secure keys (run these commands)
openssl rand -hex 32  # Copy to JWT_SECRET
openssl rand -hex 32  # Copy to ENCRYPTION_KEY
```

#### 4. Start MarkD
```bash
# From the MarkD root directory
./start.sh
```

The script will:
- ✅ Check prerequisites
- ✅ Install Python dependencies
- ✅ Install Node.js dependencies
- ✅ Start backend on port 8000
- ✅ Start frontend on port 5173

### Access MarkD

- **Frontend**: http://localhost:5173
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

**Default login:**
- Username: `admin`
- Password: `admin`

⚠️ **Change the default password immediately after first login!**

## 🛠️ Service Management

### Start Services
```bash
./start.sh
```

### Stop Services
```bash
./stop.sh
```

### Check Status
```bash
./status.sh
```

### View Logs
```bash
# Backend logs
tail -f logs/backend.log

# Frontend logs
tail -f logs/frontend.log
```

## 📁 Project Structure

```
markd/
├── backend/                 # Python FastAPI backend
│   ├── main.py             # Main application
│   ├── .env.example        # Environment template
│   ├── requirements.txt    # Python dependencies
│   └── venv/              # Virtual environment
├── frontend/               # React + TypeScript frontend
│   ├── package.json       # Node dependencies
│   └── src/               # Source code
├── database/              # Database schema
│   └── install.sql        # Installation script
├── start.sh               # Start script
├── stop.sh                # Stop script
├── status.sh              # Status checker
└── logs/                  # Log files
```

## 🔧 Configuration

### Backend Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MYSQL_HOST` | Database host | ✅ |
| `MYSQL_PORT` | Database port | ✅ |
| `MYSQL_DATABASE` | Database name | ✅ |
| `MYSQL_USER` | Database user | ✅ |
| `MYSQL_PASSWORD` | Database password | ✅ |
| `JWT_SECRET` | JWT signing key | ✅ |
| `ENCRYPTION_KEY` | Password encryption key | ✅ |

### Generate Secure Keys

```bash
# JWT Secret
openssl rand -hex 32

# Encryption Key
python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
```

## 🐛 Troubleshooting

### Backend won't start
```bash
# Check Python version
python3 --version  # Must be 3.9+

# Check dependencies
cd backend
source venv/bin/activate
pip list

# Check database connection
mysql -u markd_user -p markd
```

### Frontend won't start
```bash
# Check Node version
node --version  # Must be 18+

# Clear cache and reinstall
cd frontend
rm -rf node_modules package-lock.json
npm install
```

### Port already in use
```bash
# Find process using port
lsof -i :8000  # Backend
lsof -i :5173  # Frontend

# Kill process
kill -9 <PID>

# Or use stop script
./stop.sh
```

### Database connection failed
```bash
# Check MySQL is running
sudo systemctl status mysql

# Test connection
mysql -u markd_user -p markd

# Check .env file
cat backend/.env
```

## 🔐 Security

### Important Security Notes

1. **Change default password** immediately after installation
2. **Use strong passwords** for database and JWT keys
3. **Never commit `.env` files** to version control
4. **Use HTTPS** in production (configure reverse proxy)
5. **Regular updates** of dependencies

### Production Deployment

For production use, consider:

1. **Reverse Proxy** (Nginx/Apache) for HTTPS
2. **Process Manager** (PM2/systemd) for auto-restart
3. **Firewall** configuration
4. **Regular backups**
5. **Monitoring and logging**

Example Nginx configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;
    
    # Frontend
    location / {
        proxy_pass http://localhost:5173;
    }
    
    # Backend API
    location /api {
        proxy_pass http://localhost:8000;
    }
}
```

## 📚 More Information

- **Full Documentation**: [README.md](README.md)
- **Installation Guide**: [INSTALL.md](INSTALL.md)
- **Security Guide**: [SECURITY.md](SECURITY.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)

## 🆘 Support

If you encounter issues:

1. Check the logs in `logs/` directory
2. Run `./status.sh` for service status
3. Check this troubleshooting section
4. Create an issue on GitHub: https://github.com/xavdp-pro/markd/issues

---

**Happy documenting! 📚**

Made with ❤️ by the MarkD Team
