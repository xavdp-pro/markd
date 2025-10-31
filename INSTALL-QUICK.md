# MarkD - Quick Installation

This is the fastest way to get MarkD running on your system.

## ⚡ One-Command Installation

```bash
# Clone and setup in one command
git clone https://github.com/xavdp-pro/markd.git && cd markd && ./start.sh
```

That's it! The script handles everything.

## 📋 What the script does

1. ✅ Checks system requirements
2. ✅ Creates Python virtual environment
3. ✅ Installs all dependencies
4. ✅ Sets up database (optional)
5. ✅ Starts backend on port 8000
6. ✅ Starts frontend on port 5173

## 🔧 Manual Setup (if you prefer)

### 1. Database
```bash
mysql -u root -p
CREATE DATABASE markd CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'markd_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON markd.* TO 'markd_user'@'localhost';
EXIT;
mysql -u markd_user -p markd < database/install.sql
```

### 2. Backend
```bash
cd backend
cp .env.example .env
# Edit .env with your database settings
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 3. Frontend
```bash
cd ../frontend
npm install
```

### 4. Start
```bash
cd ..
./start.sh
```

## 🌐 Access

- **Application**: http://localhost:5173
- **API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

**Login**: admin / admin (change immediately!)

## 🛠️ Commands

```bash
./start.sh    # Start all services
./stop.sh     # Stop all services
./status.sh   # Check service status
./test.sh     # Run tests
```

## 🐛 Problems?

Check the troubleshooting section in [README-SIMPLE.md](README-SIMPLE.md).

---

**Done! 🎉 MarkD is ready to use.**
