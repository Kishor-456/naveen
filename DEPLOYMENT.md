# Deployment Guide - Car Insurance Fraud Detection App

## ⚠️ Important: Vercel Limitations

Your Flask application has ML models totaling **~121 MB** in size:
- `convnext_tiny_fraud.pth`: 106.20 MB
- `efficientnet_b0_fraud.pth`: 15.59 MB

**Vercel's deployment size limit is 100MB**, so the ConvNeXt model alone exceeds this limit. Additionally, Vercel doesn't support GPU acceleration, which may impact model performance.

---

## 🚀 Option 1: Deploy to Vercel (With Workarounds)

If you want to use Vercel, you'll need to:

1. **Exclude large model files from deployment**
2. **Download models at runtime** from a cloud storage (AWS S3, Google Cloud Storage, etc.)
3. **Accept slower inference** on serverless CPU

### Steps:

#### 1. Create `.gitignore` to exclude large files
```bash
outputs_dino2/*.pth
uploads/
__pycache__/
.env
.venv
```

#### 2. Modify `app.py` to download models from cloud storage
```python
# Add at the top after imports
import requests
import os

MODEL_DOWNLOAD_URLS = {
    'convnext': 'https://your-storage-url/convnext_tiny_fraud.pth',
    'efficientnet': 'https://your-storage-url/efficientnet_b0_fraud.pth',
    'dino_lr': 'https://your-storage-url/dinov2_logistic_regression.pkl',
    'reference': 'https://your-storage-url/deployment_reference.npz'
}

def download_models():
    output_dir = OUTPUT_FOLDER
    output_dir.mkdir(parents=True, exist_ok=True)
    
    for name, url in MODEL_DOWNLOAD_URLS.items():
        filepath = output_dir / {
            'convnext': 'convnext_tiny_fraud.pth',
            'efficientnet': 'efficientnet_b0_fraud.pth',
            'dino_lr': 'dinov2_logistic_regression.pkl',
            'reference': 'deployment_reference.npz'
        }[name]
        
        if not filepath.exists():
            print(f"Downloading {name}...")
            response = requests.get(url, stream=True)
            response.raise_for_status()
            with open(filepath, 'wb') as f:
                f.write(response.content)
```

#### 3. Deploy to Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel

# Or deploy with environment variables
vercel --prod
```

---

## ✅ Option 2: Deploy to Railway (RECOMMENDED)

Railway supports larger deployments, Python, and persistent storage.

### Steps:

1. **Sign up at https://railway.app**
2. **Create new project**
3. **Connect your GitHub repository**
4. **Configure environment variables** (if needed)
5. **Deploy!**

Railway automatically detects Python Flask apps and deploys them.

---

## ✅ Option 3: Deploy to Render

Render offers free tier with good support for Python Flask apps.

### Steps:

1. **Sign up at https://render.com**
2. **Create new Web Service**
3. **Connect GitHub repository**
4. **Set Build Command:** `pip install -r requirements.txt`
5. **Set Start Command:** `gunicorn app:app`
6. **Deploy!**

---

## ✅ Option 4: Deploy to Hugging Face Spaces

Perfect for ML apps! Hugging Face Spaces provides GPU support.

### Steps:

1. **Sign up at https://huggingface.co**
2. **Create new Space** → Select **Docker** template
3. **Upload files** or connect GitHub
4. **Create `Dockerfile`:**
```dockerfile
FROM python:3.10

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

CMD ["gunicorn", "-b", "0.0.0.0:7860", "app:app"]
```

5. **Push and it deploys automatically!**

---

## 📋 Recommended Platform Comparison

| Platform | Storage | GPU | Cold Start | Pricing |
|----------|---------|-----|------------|---------|
| **Vercel** | Limited (100MB) | ❌ | ~1s | Free |
| **Railway** | 5GB free | ❌ | ~2s | Free |
| **Render** | 1GB free | ❌ | ~5s | Free |
| **HF Spaces** | Unlimited | ✅ | ~30s | Free |
| **Heroku** | Ephemeral | ❌ | ~10s | Paid |

---

## 🔧 For Vercel Deployment (Quick Setup)

Your repository is already configured with:
- ✅ `vercel.json` - Deployment configuration
- ✅ `.vercelignore` - Files to exclude
- ✅ `requirements.txt` - Python dependencies
- ✅ Modified `app.py` - Production-ready

### Steps:

1. **Install Vercel CLI:**
```bash
npm install -g vercel
```

2. **Login to Vercel:**
```bash
vercel login
```

3. **Deploy:**
```bash
vercel --prod
```

4. **To handle model files, use Vercel Storage or cloud storage**

---

## 🎯 My Recommendation

For your ML application, I recommend **Hugging Face Spaces** because:
- ✅ Built for ML models
- ✅ Free GPU support
- ✅ Unlimited storage
- ✅ Simple Docker-based deployment
- ✅ Perfect for PyTorch applications

Otherwise, **Railway** is the best second choice for simplicity and generous free tier.

---

## 📞 Need Help?

- Vercel Docs: https://vercel.com/docs
- Railway Docs: https://docs.railway.app
- Render Docs: https://render.com/docs
- HF Spaces Docs: https://huggingface.co/docs/hub/spaces
