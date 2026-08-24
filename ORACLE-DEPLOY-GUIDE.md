# ☁️ Oracle Cloud Free Tier Par Deploy — Pura Guide (Hinglish)

Is guide mein aap **Oracle Cloud ki FREE VM** par OpenWA deploy karoge.
**Khatma:** aapka WhatsApp automation **24/7 cloud par live** — PC band ho toh bhi chalta rahega!

> ⏱️ Total time: ~45-60 min (pehli baar)
> 💰 Cost: **₹0** (Oracle Free Tier — hamesha-on VM)
> ⚠️ **Ban risk:** Cloud IP + 24/7 = zyada risk. **Sirf SECOND number** par deploy karo, main number kabhi nahi!

---

## 📌 Kya chahiye hoga
- Oracle account banane ke liye **email + debit/credit card** (sirf verification ke liye, paisa nahi katega)
- **Dusra WhatsApp number** (QR scan ke liye — main number mat use karo!)

---

## Step 1: Oracle Account Banao (10 min)

1. Browser mein kholo: **https://signup.oraclecloud.com**
2. Country: **India**, "Enterprise" nahi — **default free tier** wala signup karo
3. Email + password + details bharo
4. Card details bharo (₹1 ka temporary hold hota hai, wapas aata hai)
5. Account ready hone par email aayega (~2-5 min wait)

---

## Step 2: VM (Server) Banao — Free (10 min)

1. Login karo: **https://cloud.oracle.com**
2. Top-left **menu (☰)** → **Compute → Instances**
3. **"Create instance"** button dabao
4. **Name:** `openwa-vm` (kuch bhi)
5. **Placement:** default rahne do
6. **Image:** "Ubuntu 24.04" select karo (Change Image → Ubuntu 24.04)
7. **Shape:** "Change shape" →
   - **Specialty and legacy** mein **"Ampere"** tab kholo
   - **VM.Standard.A1.Flex** select karo
   - OCPU: **4**, Memory: **24 GB** (sab FREE hai — "Always Free eligible" dikhega)
8. **SSH keys:** "**Generate a key pair for me**" select karo
   - ✅ **Download private key** button se `.key` file save karo (Desktop par rakh lo!)
9. **Boot volume:** 47 GB default (kaafi hai)
10. **Create** dabao — VM banne mein 2-3 min

> ⭐ **Static IP reserve karo (recommended):** Menu → Networking → **Reserved public IPs** → Reserve IP → apne VM se link karo. Toh IP kabhi nahi badlega.

---

## Step 3: Port 2785 Kholo (Security List) (5 min)

1. Menu → **Networking → Virtual cloud networks**
2. Apni VCN par click → **Security Lists** → **Default Security List**
3. **Add Ingress Rules** →
   - Source CIDR: `0.0.0.0/0`
   - IP Protocol: **TCP**
   - Destination Port Range: **2785**
   - **Add Ingress Rules** save karo
   - (Port 22 SSH already khula hota hai — woh mat hatao)

---

## Step 4: VM Par OpenWA Install Karo (Cloud Shell se) (15 min)

Oracle ke **Cloud Shell** = browser mein built-in terminal — kuch install nahi karna!

1. Instance list mein apna VM kholo — **Public IP address** note karo (jaise `129.146.xx.xx`)
2. Page ke **top-right** mein **Cloud Shell** icon (">_") click karo — terminal khulega
3. Private key upload karo: Cloud Shell mein **⋯ (three dots) → Upload** → apni `.key` file select karo
4. Ye commands copy-paste karo (ek-ek karke Enter dabao):

```bash
ls *.key
chmod 600 *.key
ssh -i *.key ubuntu@<YOUR_VM_IP>
```

> `<YOUR_VM_IP>` ki jagah apna Public IP daalo. "Are you sure?" puchhe toh `yes` likho.

5. **Login hone ke baad** — ye ek-line command chalao (sab kuch khud ho jayega — Docker install, OpenWA build, start):

```bash
curl -fsSL https://raw.githubusercontent.com/ujagare/Whatsaap-Automation-/main/oracle-setup.sh -o setup.sh && bash setup.sh
```

> ⏳ Build mein **10-20 min** lagenge — bas wait karo, kuch mat dabao.
> Last mein aisa dikhega:
> ```
> DONE!
> OpenWA URL : http://<VM_IP>:2785
> ```

6. API key nikaalo:

```bash
sudo cat ~/openwa-data/.api-key
```

> Yeh **API key** copy karke save kar lo — aage chahiye hogi.

---

## Step 5: WhatsApp Pair Karo (QR Scan) (5 min)

**Apne PC par** (is whatsaap folder mein) ye PowerShell command chalao:

```powershell
pwsh oracle-qr-pair.ps1 -VM_IP <YOUR_VM_IP>
```

1. API key paste karo (Step 4 wali)
2. **QR code** apne screen par khulega
3. **Dusre WhatsApp number** ke phone se scan karo:
   WhatsApp → Settings (⚙️) → Linked devices → **Link a device**
4. Script khud status dikhayega — **`ready`** aate hi:

```
==============================================
 CONNECTED! WhatsApp automation ab cloud par live hai!
==============================================
```
5. **3 automation rules bhi khud ban jayenge** (Away auto-reply, Price enquiry, Help request)

---

## ✅ Test Karo

Kisi se bol do dusre number par **"price"** bhejne ko → auto-reply aayega!
PC band karo, Wi-Fi band karo — **cloud par automation chalta rahega!** 🎉

---

## 🛠️ Baad Mein Kaam Ke Commands

| Kaam | Command (Cloud Shell se) |
|---|---|
| Server logs dekho | `sudo docker logs openwa --tail 50` |
| Server restart karo | `sudo docker restart openwa` |
| Server band karo | `sudo docker stop openwa` |
| Server chalu karo | `sudo docker start openwa` |
| Naya update lagaao | `cd ~/whatsaap && git pull && sudo docker build -t openwa:local . && sudo docker rm -f openwa && sudo docker run -d --name openwa --restart=always -p 2785:2785 -v ~/openwa-data:/app/data -e NODE_ENV=production -e ENGINE_TYPE=whatsapp-web.js -e DATABASE_TYPE=sqlite -e DATABASE_NAME=./data/openwa.sqlite -e DATABASE_SYNCHRONIZE=true openwa:local` |
| API key dekho | `sudo cat ~/openwa-data/.api-key` |
| Data backup | `sudo tar -czf ~/openwa-data-backup.tar.gz ~/openwa-data` |

---

## 🔄 Local vs Cloud — Kaunsa Chale?

- **Local wala** (port 2785) — abhi bhi chal raha hai, dono saath chal sakte hain **par ek number ek hi jagah active** — do jagah same number pair karo toh ek disconnect hoga
- **Cloud wala** — dusre number ke saath, 24/7
- Kabhi bhi dono ko ek saath nahi chala sakte **same number** par

## ⚠️ Yaad Rakho
- **Main WhatsApp number kabhi cloud par mat lagao** — ban ka risk sabse zyada
- Oracle free VM **kabhi so nahi jata** (Render jaisa sleep nahi!) — isliye yeh sabse best free option hai
- Machine restart ho toh bhi container khud start ho jata hai (`restart: always`)
