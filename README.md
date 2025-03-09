# 🎁 Hedieaty - Gift List Management App 🎁

**Hedieaty** is a gift list management app designed to streamline the process of creating, managing, and sharing wish lists for special occasions such as birthdays, weddings, graduations, and holidays. The app provides a user-friendly experience, allowing users to create, modify, and share wish lists while integrating advanced features like barcode scanning, real-time cloud syncing, and notifications.

---

## 📱 Features

### **1️⃣ UI Layout & Design**
- **Home Page**: Displays a list of friends with profile pictures and upcoming events.
- **Event List Page**: Manage events (Add, Edit, Delete) and view upcoming/current/past events.
- **Gift List Page**: Add, edit, delete gifts; visualize pledged gifts.
- **Gift Details Page**: View detailed gift information, upload images, and mark gifts as pledged.
- **Profile Page**: Manage user profile, view events & pledged gifts.
- **My Pledged Gifts Page**: Track gifts pledged by the user.

### **2️⃣ Database Integration**
- **Local Storage**: Uses SQLite to store user data, events, gifts, and friends.
- **Table Structure**:
  - `Users`: Stores user information (ID, name, email, preferences).
  - `Events`: Stores event details (ID, name, date, location, etc.).
  - `Gifts`: Stores gift information (ID, name, category, price, status).
  - `Friends`: Stores user-friend relationships.

### **3️⃣ Real-Time Cloud Sync**
- **Firebase Realtime Database** ensures users can sync their gift lists across devices.
- **Firebase Authentication** secures user accounts.
- **Live Updates**: Pledged and purchased gifts update in real-time.

### **5️⃣ Quality Enhancements**
- **Smooth Animations**: Improved user experience with fluid transitions.
- **Notifications**:
  - Firebase Cloud Messaging alerts users when someone pledges a gift.
  - In-app notifications for gift status updates.
- **Advanced Search & Filtering**: Find gifts based on category, name, or event.
- **Data Validation**: Ensures correct inputs and prevents incorrect data entry.

### **6️⃣ Automated Testing**
- **Flutter Test Framework**: Unit tests and integration tests for core functionalities.
- **Auto-Test Script**: Runs automated tests via ADB commands (Bash/PowerShell).

### **7️⃣ Documentation & Deployment**
- **Comprehensive User Guide** with setup instructions.
- **Version Control Management**: The project is maintained using **Git**.
- **Deployment**:
  - The app will be published on the **Google Play Store, Apple App Store, and Amazon App Store**.
  - A demonstration video is available on **YouTube**.

---

## 🚀 Tech Stack
| Technology  | Purpose |
|-------------|---------|
| **Flutter (Dart)** | Frontend UI & App Logic |
| **SQLite** | Local database storage |
| **Firebase Realtime Database** | Cloud synchronization |
| **Firebase Authentication** | User authentication |
| **Git & GitHub** | Version control |

---

