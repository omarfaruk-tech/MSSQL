#!/bin/bash
# ======================================================================
# Script Name: install_mssql.sh
# OS: Ubuntu 24.04 (Noble Numbat)
# Target: Microsoft SQL Server 2022 (Express Edition)
# Description: Installs MSSQL 2022, fixes OpenLDAP 2.5 dependency, and configures.
# =====================================================================
# Error হলে স্ক্রিপ্ট থামানোর জন্য
set -e

echo "===================================================="
# 1. System Update ও প্রয়োজনীয় Tool ইনস্টল
echo "Step 1: System update ও প্রয়োজনীয় টুলস ইনস্টল করা হচ্ছে..."
# ==============================================================================
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl gnupg2 software-properties-common apt-transport-https

echo "===================================================="
# 2. Ubuntu 22.04 এর libldap-2.5-0 ইনস্টল (Ubuntu 24.04 Dependency Fix)
echo "Step 2: OpenLDAP 2.5 dependency ফিক্স করা হচ্ছে..."
# ======================================================================
cd /tmp
# আগে থেকে কোনো পুরানো বা ভাঙা ফাইল থাকলে তা পরিষ্কার করা
sudo rm -f libldap-2.5-0_*.deb
sudo rm -f /usr/lib/x86_64-linux-gnu/libldap-2.5.so.0
sudo rm -f /usr/lib/x86_64-linux-gnu/liblber-2.5.so.0

# সঠিক প্যাকেজ ডাউনলোড ও ইনস্টল
wget http://security.ubuntu.com/ubuntu/pool/main/o/openldap/libldap-2.5-0_2.5.16+dfsg-0ubuntu0.22.04.2_amd64.deb
sudo dpkg -i libldap-2.5-0_2.5.16+dfsg-0ubuntu0.22.04.2_amd64.deb || sudo apt-get install -f -y

echo "===================================================="
# 3. MSSQL 2022 Repository যোগ করা
echo "Step 3: MSSQL 2022 রিপোজিটরি যোগ করা হচ্ছে..."
# =====================================================================
# সিস্টেমের মেইন ফাইল বা অন্য কোনো ফাইলে মাইক্রোসফটের এন্ট্রি থাকলে তা গোড়া থেকে মুছে ফেলা হচ্ছে
sudo sed -i '/packages.microsoft.com/d' /etc/apt/sources.list
sudo sed -i '/packages.microsoft.com/d' /etc/apt/sources.list.d/ubuntu.sources
sudo rm -f /etc/apt/sources.list.d/*microsoft*
sudo rm -f /etc/apt/sources.list.d/*mssql*
sudo rm -f /etc/apt/sources.list.d/*msprod*

# কোনো পুরনো কনফ্লিক্ট ফাইল থাকলে তা আগে মুছে ফেলা হচ্ছে
sudo rm -f /etc/apt/sources.list.d/mssql-server-2022.list
sudo rm -f /etc/apt/sources.list.d/msprod.list
sudo rm -f /etc/apt/sources.list.d/microsoft*.list

# Microsoft GPG Key যোগ করা
curl https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --yes --dearmor -o /usr/share/keyrings/microsoft-prod.gpg

# Ubuntu 24.04 এর জন্য সরাসরি repo না থাকায় 22.04 (Jammy) এর MSSQL 2022 repo ব্যবহার করা হচ্ছে
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/mssql-server-2022 jammy main" | sudo tee /etc/apt/sources.list.d/mssql-server-2022.list

echo "===================================================="
# 4. MSSQL Server ইনস্টল করা
echo "Step 4: mssql-server প্যাকেজ ইনস্টল করা হচ্ছে..."
# ==================================================================
sudo apt update
sudo apt install -y mssql-server

echo "===================================================="
# 5. OpenSSL 3.0 Compatibility Force Fix
echo "Step 5: Ubuntu 24.04 এর OpenSSL 3.0 এর জন্য কনফিগারেশন ফিক্স করা হচ্ছে..."
# =====================================================================
# Force encryption বন্ধ করা (যাতে OpenSSL 1.1 এর অভাবে ক্র্যাশ না করে)
sudo /opt/mssql/bin/mssql-conf set network.forceencryption 0

echo "===================================================="
# 6. MSSQL Initial Setup ও পাসওয়ার্ড সেটআপ
echo "Step 6: MSSQL Setup রান করা হচ্ছে..."
echo "গুরুত্বপূর্ণ: এখন আপনাকে Edition (যেমন: 3 for Express) সিলেক্ট করতে হবে এবং SA পাসওয়ার্ড দিতে হবে।"
# ===================================================================
sudo /opt/mssql/bin/mssql-conf setup

echo "===================================================="
# 7. MSSQL Tools (sqlcmd) ইনস্টল করা
echo "Step 7: CLI Tools (sqlcmd) ইনস্টল করা হচ্ছে..."
# ============================================================
echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/microsoft-prod.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" | sudo tee /etc/apt/sources.list.d/msprod.list
sudo apt update
sudo ACCEPT_EULA=Y apt install -y mssql-tools18 unixodbc-dev

# পরিবেশ চলক (Environment Variables) যোগ করা যাতে সরাসরি 'sqlcmd' কমান্ড কাজ করে
echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
source ~/.bashrc

echo "===================================================="
# 8. স্ট্যাটাস চেক করা
echo "Step 8: MSSQL সার্ভিসের বর্তমান স্ট্যাটাস..."
# =============================================================
sudo systemctl enable mssql-server
sudo systemctl restart mssql-server
sudo systemctl status mssql-server --no-pager

echo "===================================================="
echo "সফলভাবে MSSQL 2022 ইনস্টল এবং কনফিগার হয়েছে!"
echo "টিপস: নতুন টার্মিনাল খুলে কানেক্ট করতে ব্যবহার করুন: sqlcmd -S localhost -U sa -P 'আপনার_পাসওয়ার্ড' -C"
echo "===================================================="
