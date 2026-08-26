# 🛡️ Privacy Policy Web Page - Host & Google Play Console Guide

Target Folder: `privacy_policy/`  
Main Web File: `privacy_policy/index.html`

---

## 🌟 Overview
This web page is designed specifically for **Task Manager App**. It features:
- **Play Store Compliance**: Covers Google Play Console requirements (Permissions, Third-Party SDKs like Firebase, Data Retention, Account Deletion, Children's Privacy).
- **Matching Design System**: Dark theme (`#0F172A`), Indigo gradients (`#4F46E5` / `#818CF8`), glassmorphism cards, Inter/Poppins fonts, responsive sidebar navigation.
- **Interactive Features**: Dark / Light theme toggle, print support, smooth scroll anchor links.

---

## 🚀 Free Hosting Options (To get HTTPS URL for Google Play Console)

Google Play Console requires a **public HTTPS URL** for your Privacy Policy. Here are the 3 fastest free hosting options:

### Option 1: GitHub Pages (Recommended - 2 Minutes)
1. Push your project or the `privacy_policy` folder to a public/private GitHub repository.
2. In GitHub, go to **Settings** -> **Pages**.
3. Under **Build and deployment**, select `main` (or `master`) branch and set folder to `/privacy_policy` (or root if uploaded as separate repo).
4. Click **Save**. GitHub will generate your free URL:
   `https://<your-username>.github.io/<repo-name>/privacy_policy/`

---

### Option 2: Vercel (1 Minute - Super Fast)
1. Go to [Vercel.com](https://vercel.com) (Log in with GitHub).
2. Click **Add New Project** -> Import your GitHub repository.
3. Set Root Directory to `privacy_policy`.
4. Click **Deploy**. Vercel will instantly give you a free domain:
   `https://task-manager-privacy-policy.vercel.app`

---

### Option 3: Netlify (Drag & Drop - 30 Seconds)
1. Go to [Netlify Drop](https://app.netlify.com/drop).
2. Drag and drop the `privacy_policy` folder directly into the browser window.
3. Netlify will instantly create an HTTPS URL for you!

---

## 📲 How to set this URL in Google Play Console

1. Log into your **Google Play Console**.
2. Select your **Task Manager** app.
3. Navigate to **Policy** -> **App Content** -> **Privacy Policy**.
4. Paste your public HTTPS Privacy Policy URL (e.g. `https://yourdomain.vercel.app` or `https://github.io/...`).
5. Click **Save**.

---

## ✏️ How to Customize Contact Email & App Details
Support email is set to `meetmobiledev@gmail.com` in section 9 of `privacy_policy/index.html`. You can update developer name or studio name in the footer/contact box as needed.
