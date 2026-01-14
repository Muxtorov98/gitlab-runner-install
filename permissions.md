# 🚀 Deploy Permission Setup (User + GitLab Runner)

Ushbu hujjat **production serverda**:
- oddiy `user`
- `gitlab-runner`

ikkalasi ham **bir xil loyiha papkasi** (`/var/www/app`) bilan muammosiz ishlashi uchun
**to‘g‘ri permission va ownership** sozlashni tushuntiradi.

---

## 🎯 Maqsad

- ❌ `sudo` ishlatmasdan deploy qilish
- ❌ Git permission xatolarini yo‘qotish
- ❌ GitLab CI’da `permission denied` va `dubious ownership` muammolarini bartaraf etish
- ✅ `user` va `gitlab-runner` bir xil huquqda ishlashi

---

## 👥 Ishchi userlar

| User | Vazifa |
|-----|-------|
| `user` | Manual deploy, debugging |
| `gitlab-runner` | CI/CD pipeline |
| `deploy` (group) | Umumiy deploy huquqlari |

---

## 🧱 1-qadam: `deploy` guruhini yaratish

```bash
sudo groupadd deploy
```
## 2-qadam: Userlarni guruhga qo‘shish

```bash
sudo usermod -aG deploy gitlab-runner
sudo usermod -aG deploy user
```
- Eslatma: Guruh o‘zgarishi kuchga kirishi uchun userlar logout/login qilishi kerak.

## 3-qadam: Loyiha papkasini guruhga berish

```bash
sudo chown -R user:deploy /var/www/app
```

## Bu yerda:
- `Owner` → `user`
- `Group` → `deploy`

# 4-qadam: Permission sozlash

```bash
sudo chmod -R 775 /var/www/hub.bts.uz
```

## Bu nimani anglatadi:
- `Owner (user)` → to‘liq huquq
- `Group (deploy)` → to‘liq huquq
- `Others` → faqat o‘qish

## 5-qadam: Yangi papkalar ham guruhni meros qilib olishi uchun

```bash
sudo find /var/www/app -type d -exec chmod g+s {} \;
```

## Bu juda muhim:
- Git
- Composer
- CI

yaratgan yangi papkalar avtomatik deploy guruhida bo‘ladi

# Tekshirish

```bash
ls -ld /var/www/app
```

## Kutilgan natija:

```bash
drwxrwxr-x user deploy /var/www/app
```



