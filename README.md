# MSSQL
MSSQL 2022 in Ubuntu 24.04 - 1 Click

  স্ক্রিপ্টটি যেভাবে রান করবেন:

ধাপ ১: সার্ভারে ফাইলটি তৈরি করুন:nano install_mssql.sh
(কোডটি পেস্ট করে Ctrl+O তারপর Enter চাপুন, এবং Ctrl+X দিয়ে বের হয়ে আসুন)

ধাপ ২: স্ক্রিপ্টটিকে এক্সিকিউটেবল (Executable) করুন: chmod +x install_mssql.sh

ধাপ ৩: স্ক্রিপ্টটি রান করুন: ./install_mssql.sh

  স্ক্রিপ্ট রান করার সময় আপনার কাজ:

স্ক্রিপ্টটি নিজে নিজেই সব ডাউনলোড ও ফিক্স করে Step 6-এ এসে আপনার কাছে জানতে চাইবে:

Choose an edition of SQL Server: এখানে 3 চাপুন (Express edition এর জন্য, বা আপনার লাইসেন্স অনুযায়ী অন্যটি)।        
Accept the license terms: এখানে Yes লিখুন।  
Enter the SQL Server system administrator password: এখানে আপনার SA ইউজারের জন্য একটি স্ট্রং পাসওয়ার্ড দিন (পাসওয়ার্ডে ক্যাপিটাল লেটার, স্মল লেটার, নাম্বার এবং স্পেশাল ক্যারেক্টার থাকতে হবে)।

