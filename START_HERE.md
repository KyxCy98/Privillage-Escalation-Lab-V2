# 🎯 START HERE - Advanced Privilege Escalation Lab

## 👋 Welcome!

Anda telah berhasil download **Advanced Privilege Escalation Lab** - lab pelatihan keamanan profesional dengan 7 tahap exploit chain yang saling terhubung.

---

## � IMPORTANT: Bug Fix Required!

⚠️ **If you previously tried to run the lab and got "Permission denied" SSH error:**

Please rebuild with the latest fix:
```bash
cd c:\Users\Hype GLK\Downloads\lab
./build.sh clean
./build.sh build-and-run
sleep 60
ssh -p 2222 player1@localhost  # password: password123
```

See [BUGFIX.md](BUGFIX.md) for details about the SSH permission issue and how it was fixed.

---

## �📦 Apa yang Anda Dapatkan?

### ✅ Complete Lab Setup
- Docker container dengan multiple users, services, dan vulnerabilities
- 7-stage privilege escalation chain yang saling terhubung
- Black box exploitation challenge (minimal hints)
- Real-world skenario dengan multiple attack vectors

### ✅ Comprehensive Documentation
- **README.md** - Panduan lengkap setiap stage
- **SOLUTION.md** - Walkthrough detail dengan command
- **VULNERABILITIES.md** - Analisis teknis setiap CVE/CWE
- **CHEATSHEET.txt** - Quick reference untuk semua command
- **INDEX.md** - Navigasi lengkap dokumentasi

### ✅ Helper Tools
- **build.sh** - Script untuk build/run/manage container
- **docker-compose.yml** - Alternative setup dengan Docker Compose
- **exploit-template.sh** - Reference exploitation script
- **CHECKLIST.md** - Verification checklist

---

## 🚀 3-Step Quick Start

### Step 1: Install Docker
Pastikan Docker ter-install:
```bash
docker --version
```

### Step 2: Build & Run Lab
```bash
cd c:\Users\Hype GLK\Downloads\lab
./build.sh
```

Atau jika tidak bisa jalankan script:
```bash
docker build -t privesc-lab .
docker run -d --name privesc-lab -p 2222:22 privesc-lab
```

### Step 3: SSH & Exploit
```bash
ssh -p 2222 player1@localhost
# Password: password123
```

---

## 📚 Documentation Roadmap

### Untuk Pemula ⭐
1. Baca: **QUICKSTART.md** (5 menit)
2. Baca: **README.md** - Stage 1 & 2 (15 menit)
3. Coba: Exploit sendiri dengan hints dari README
4. Jika stuck: Lihat **SOLUTION.md**

### Untuk Intermediate ⭐⭐
1. Baca: **README.md** semua stage (30 menit)
2. Coba: Exploit semua stage dari scratch
3. Baca: **VULNERABILITIES.md** untuk detail teknis (60 menit)
4. Baca: **SOLUTION.md** untuk review & belajar alternatif method

### Untuk Advanced ⭐⭐⭐
1. Scan: **README.md** untuk overview (10 menit)
2. Exploit: Semua stage dari scratch tanpa bantuan
3. Deep-dive: **VULNERABILITIES.md** untuk CVE/CWE details (90 menit)
4. Improve: Hardening & remediation strategies

---

## 🎯 7 Tahap Privilege Escalation

| # | Stage | Vulnerability | Time |
|---|-------|---|---|
| 1️⃣ | Initial Access | Weak SSH Credentials | 2-5 min |
| 2️⃣ | User Enumeration | Insecure File Permissions | 5-10 min |
| 3️⃣ | SUID Exploitation | PATH Injection Attack | 10-15 min |
| 4️⃣ | Database Access | Weak DB Credentials | 5 min |
| 5️⃣ | Secrets Extraction | Environment Variables | 5 min |
| 6️⃣ | Sudo Escalation | NOPASSWD Misconfiguration | 5-10 min |
| 7️⃣ | Root Access | Complete Chain | 5-10 min |

**Total Time: 40-60 menit untuk complete exploitation**

---

## 📋 File Structure

```
lab/
├── 📖 DOKUMENTASI
│   ├── START_HERE.md ................. File ini (intro)
│   ├── README.md .................... Panduan lengkap
│   ├── QUICKSTART.md ................ Setup cepat
│   ├── SOLUTION.md .................. Solusi detail
│   ├── VULNERABILITIES.md ........... Analisis teknis
│   ├── CHECKLIST.md ................. Verification guide
│   ├── INDEX.md ..................... Navigasi dokumentasi
│   └── CHEATSHEET.txt ............... Quick reference
│
├── 🐳 DOCKER
│   ├── Dockerfile ................... Container definition
│   ├── docker-compose.yml ........... Docker Compose setup
│   ├── setup-lab.sh ................. Main setup script
│   ├── stage1-setup.sh .............. Stage 1 placeholder
│   ├── vulnerable-service.py ....... Vulnerable Python app
│   └── suid-binary.c ................ Vulnerable C binary
│
├── 🛠️ TOOLS & HELPERS
│   ├── build.sh ..................... Build/run helper
│   ├── exploit-template.sh .......... Reference exploitation
│   └── .gitignore ................... Git ignore
```

---

## 🔑 Credentials Cheat Sheet

### SSH Access
- **Host:** localhost
- **Port:** 2222
- **User:** player1
- **Password:** password123

### Database
- **PostgreSQL** - localhost:5432
  - User: `pwner`
  - Pass: `password123`

- **MySQL** - localhost:3306
  - User: `root`
  - Pass: `SuperSecret@2024`

### Other Users
- **backup** - `BackupPass@123`
- **jenkins** - `JenkinsCI@2024`
- **devops** - `DevOps123#`

---

## 🎓 Apa yang Akan Anda Pelajari?

✅ User enumeration & reconnaissance techniques  
✅ Weak credential exploitation  
✅ SUID binary vulnerabilities & exploitation  
✅ PATH manipulation attacks  
✅ Database security weaknesses  
✅ Configuration file exploitation  
✅ Sudo misconfiguration attacks  
✅ Privilege escalation chaining  
✅ Complete attack chain construction  
✅ Security remediation & hardening  

---

## ⚡ Quick Command Reference

### Build & Run
```bash
./build.sh                    # Build dan run (default)
./build.sh clean              # Cleanup
./build.sh status             # Check status
./build.sh logs               # View logs
```

### SSH Access
```bash
ssh -p 2222 player1@localhost
# Password: password123
```

### Find Documentation
```bash
ls -la *.md              # Semua dokumentasi
cat README.md            # Panduan lengkap
cat CHEATSHEET.txt       # Command reference
```

---

## 🆘 Troubleshooting

### SSH Connection Refused?
```bash
# Tunggu 60 detik untuk SSH daemon startup
sleep 60
ssh -p 2222 player1@localhost
```

### Docker Not Running?
```bash
# Check Docker daemon
docker ps

# Jika error, start Docker Desktop atau daemon
```

### Port 2222 Already in Use?
```bash
# Use different port
docker run -d -p 3333:22 privesc-lab
ssh -p 3333 player1@localhost
```

---

## 📞 Documentation Quick Links

| Keperluan | File | Time |
|-----------|------|------|
| Setup cepat | [QUICKSTART.md](QUICKSTART.md) | 5 min |
| Overview lengkap | [README.md](README.md) | 30 min |
| Solusi detail | [SOLUTION.md](SOLUTION.md) | 45 min |
| Analisis teknis | [VULNERABILITIES.md](VULNERABILITIES.md) | 90 min |
| Quick reference | [CHEATSHEET.txt](CHEATSHEET.txt) | 5 min |
| Verification | [CHECKLIST.md](CHECKLIST.md) | 20 min |
| Navigasi semua | [INDEX.md](INDEX.md) | 10 min |

---

## 🎯 Rekomendasi Urutan Belajar

### Hari 1: Setup & Stage 1-2
1. Jalankan `./build.sh`
2. Baca [QUICKSTART.md](QUICKSTART.md)
3. Baca [README.md](README.md) - Stage 1 & 2
4. SSH ke lab
5. Exploit Stage 1 & 2

### Hari 2: Stage 3-4
1. Baca [README.md](README.md) - Stage 3 & 4
2. Attempt exploitation
3. Cek [SOLUTION.md](SOLUTION.md) untuk hints
4. Exploit Stage 3 & 4

### Hari 3: Stage 5-7
1. Baca [README.md](README.md) - Stage 5,6,7
2. Exploit Stage 5
3. Exploit Stage 6
4. Exploit Stage 7 (Gain Root!)

### Hari 4: Deep Learning
1. Baca [VULNERABILITIES.md](VULNERABILITIES.md)
2. Pahami CVE/CWE setiap stage
3. Pelajari remediation strategies
4. Practice ulang tanpa melihat solutions

---

## 🔐 Ethical Guidelines

⚠️ **PENTING:**
- Lab ini untuk **training & education ONLY**
- Hanya gunakan di **authorized environments**
- Jangan deploy vulnerable code ke production
- Gunakan knowledge ini untuk **improve security**
- Respect **responsible disclosure** principles

---

## 💡 Pro Tips

1. **Baca dokumentasi dulu** sebelum attempt exploitation
2. **Gunakan CHEATSHEET.txt** untuk quick reference commands
3. **Log semua command** untuk documentation & learning
4. **Pahami WHY** bukan hanya HOW
5. **Try alternatives** - ada multiple paths ke root
6. **Cleanup** setelah selesai (`./build.sh clean`)

---

## 📊 Lab Statistics

- **Total Stages:** 7
- **Vulnerability Types:** 15+
- **Attack Vectors:** 5+ per stage
- **CVSS Scores:** 5.3 - 9.8 (High to Critical)
- **Exploitation Time:** 40-60 menit
- **Learning Value:** ⭐⭐⭐⭐⭐

---

## 🚀 Let's Get Started!

### Pilihan 1: Fast Track (30 min)
```bash
./build.sh
# Tunggu container ready
ssh -p 2222 player1@localhost  # password: password123
cat README.md | head -50  # Baca overview
# Start exploiting!
```

### Pilihan 2: Thorough Track (2 hours)
```bash
./build.sh
# Baca semua documentation
cat QUICKSTART.md
cat README.md
# Then SSH and exploit
ssh -p 2222 player1@localhost
# Exploit dengan understanding
```

### Pilihan 3: Study Track (4+ hours)
```bash
./build.sh
# Baca semua documentation
cat INDEX.md          # Navigasi
cat README.md         # Overview
cat SOLUTION.md       # Solutions
cat VULNERABILITIES.md # Technical
# SSH dan exploit
ssh -p 2222 player1@localhost
# Practice dengan full understanding
```

---

## 📝 Checklist Sebelum Mulai

- [ ] Docker ter-install dan running
- [ ] 2GB RAM tersedia
- [ ] 2GB disk space tersedia
- [ ] SSH client ter-install
- [ ] Terminal/bash ready
- [ ] Dokumentasi tersedia (Anda sedang membacanya!)

✅ **Semua siap? Mari mulai!**

```bash
cd c:\Users\Hype GLK\Downloads\lab
./build.sh
```

---

## ❓ FAQ

**Q: Berapa lama lab?**
A: 40-60 menit untuk complete exploitation (belum termasuk learning)

**Q: Berapa disk space dibutuhkan?**
A: ~2-3 GB untuk Docker image

**Q: Bisa di Windows/Mac?**
A: Ya! Docker Desktop support semua OS

**Q: Bisa collaborative?**
A: Ya, tapi perlu buat multiple containers untuk setiap user

**Q: Ada backdoor/cheat?**
A: Nope! Pure black-box challenge

---

## 📞 Support

- **Setup Issues?** → Cek [QUICKSTART.md](QUICKSTART.md)
- **Exploitation Help?** → Cek [README.md](README.md)
- **Stuck Completely?** → Lihat [SOLUTION.md](SOLUTION.md)
- **Want Deep Dive?** → Baca [VULNERABILITIES.md](VULNERABILITIES.md)
- **Verify Lab?** → Ikuti [CHECKLIST.md](CHECKLIST.md)

---

## 🎊 Ready?

**Klik salah satu untuk mulai:**

1. **Fast & Practical** → [QUICKSTART.md](QUICKSTART.md)
2. **Comprehensive** → [README.md](README.md)
3. **Already Stuck?** → [SOLUTION.md](SOLUTION.md)
4. **Technical Deep Dive** → [VULNERABILITIES.md](VULNERABILITIES.md)
5. **Verify Everything** → [CHECKLIST.md](CHECKLIST.md)

---

## 🏁 Final Notes

> "The best way to learn security is by breaking things (ethically)"

Lab ini dirancang untuk:
- ✅ Practical learning
- ✅ Real-world scenarios  
- ✅ Deep understanding
- ✅ Team training

Selamat belajar! 🎓

---

**Next Step:** 
```bash
./build.sh && ssh -p 2222 player1@localhost
```

**Password:** `password123`

Good luck! 🚀
