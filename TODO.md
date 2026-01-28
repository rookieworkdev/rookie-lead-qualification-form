# Recruitment Webhook - Deployment TODO

## ✅ Completed
- [x] Set up Express.js webhook server
- [x] Configure Resend for email sending
- [x] Configure OpenAI for lead scoring
- [x] Configure Supabase for data storage
- [x] Test locally - all flows working
- [x] Modified email to send to rookiework.dev@gmail.com (testing mode)

## 🚀 Next Steps

### 1. Deploy Webhook to Production

**Vercel works for this** (serverless, spins up on demand - perfectly fine for webhooks!)

#### Option A: Deploy to Vercel (Recommended - Easy & Free)

**Steps:**
1. **Initialize Git**:
   ```bash
   cd /Users/hanna/Desktop/recruitment-webhook
   git init
   git add .
   git commit -m "Initial recruitment webhook setup"
   ```

2. **Push to GitHub**:
   - Create new repo at github.com/new
   - Name it: `recruitment-webhook`
   - Run:
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/recruitment-webhook.git
   git push -u origin main
   ```

3. **Deploy to Vercel**:
   - Go to [vercel.com/new](https://vercel.com/new)
   - Import your `recruitment-webhook` repo
   - Click "Deploy"
   - Add environment variables (see below)

4. **Add Environment Variables in Vercel**:
   Settings → Environment Variables → Add each:
   ```
   NODE_ENV=production
   OPENAI_API_KEY=<your-openai-key>
   SUPABASE_URL=<your-supabase-url>
   SUPABASE_KEY=<your-supabase-service-role-key>
   RESEND_API_KEY=<your-resend-key>
   RESEND_FROM_EMAIL=onboarding@resend.dev
   ```

   **Copy values from your local .env file**

5. **Get your webhook URL**:
   ```
   https://your-webhook-project.vercel.app/api/webhook
   ```

**Note**: Vercel serverless is PERFECT for webhooks - it spins up when needed (< 1 second cold start), handles the request, then spins down. This is ideal and cost-effective.

#### Option B: Deploy to Railway (Always-On Alternative)

If you prefer a traditional always-on server:

1. Go to [railway.app](https://railway.app)
2. New Project → Deploy from GitHub
3. Select your repo
4. Add environment variables
5. Railway gives you: `https://your-app.railway.app/api/webhook`

**Cost**: Free tier available, then ~$5/month

---

### 2. Update Website Form Code

**In your website repo** (https://rookie-2-0.vercel.app/), update the form submission handler:

#### Find Your Form Component
Location likely: `src/components/ContactForm.tsx` or similar

#### Update the fetch call:

**Before** (probably something like):
```typescript
const handleSubmit = async (formData) => {
  // ... validation

  // Old: maybe posting to your own API route
  const response = await fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
  });
}
```

**After**:
```typescript
const handleSubmit = async (formData) => {
  // ... validation

  // New: post to your deployed webhook
  const response = await fetch('https://your-webhook-project.vercel.app/api/webhook', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: formData.name,
      email: formData.email,
      phone: formData.phone,
      company: formData.company,
      industry: formData.industry,
      service_type: formData.serviceType, // or however it's named
      message: formData.message,
      subject: formData.subject || 'General inquiry'
    })
  });

  if (response.ok) {
    // Success - show thank you message
    const result = await response.json();
    console.log('Lead classification:', result.classification);
  } else {
    // Error handling
    console.error('Webhook failed');
  }
}
```

**Required form fields mapping**:
```
Form Field          → Webhook Field
-----------------   → ---------------
name                → name
email               → email
phone               → phone
company             → company
industry            → industry
serviceType         → service_type
message/description → message
subject (optional)  → subject
```

---

### 3. Verify Resend Domain (For Production Email)

**Current limitation**: Emails only go to rookiework.dev@gmail.com

**To send to actual leads**:

1. **Go to**: [resend.com/domains](https://resend.com/domains)
2. **Add domain**: `rookiework.se` (or whatever domain you own)
3. **Add DNS records** (Resend will show you what to add)
4. **Wait for verification** (~5 minutes to 24 hours)
5. **Update code** in `src/services/emailService.js`:
   ```javascript
   // Change line 208 from:
   to: 'rookiework.dev@gmail.com',

   // To:
   to: [leadEmail, 'hanna.hosk@gmail.com'], // Send to lead + you
   ```
6. **Update `.env`**:
   ```
   RESEND_FROM_EMAIL=noreply@rookiework.se
   ```
7. **Redeploy** to Vercel

---

### 4. Testing After Deployment

**Test webhook directly**:
```bash
curl -X POST https://your-webhook-project.vercel.app/api/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@company.com",
    "phone": "0701234567",
    "company": "Test AB",
    "industry": "technology",
    "service_type": "direktrekrytering",
    "message": "Vi behöver rekrytera en utvecklare",
    "subject": "Test"
  }'
```

**Test from your website**:
1. Go to your contact form
2. Fill it out
3. Submit
4. Check:
   - Response in browser console
   - Email at rookiework.dev@gmail.com
   - Supabase tables for new records

---

### 5. Monitoring & Maintenance

**Check logs**:
- Vercel: Project → Logs tab
- Railway: Project → Deployments → Logs

**Monitor Supabase**:
- Check tables regularly: companies, signals, contacts, website_jobs

**Check Resend dashboard**:
- [resend.com/emails](https://resend.com/emails) - see all sent emails

---

## 📋 Deployment Checklist

- [ ] Push code to GitHub
- [ ] Deploy to Vercel/Railway
- [ ] Add all environment variables
- [ ] Test webhook URL directly (curl)
- [ ] Update website form to use new webhook URL
- [ ] Test form submission from website
- [ ] Verify email received
- [ ] Verify data in Supabase
- [ ] Set up Resend domain (when ready)
- [ ] Update email sending code (after domain verified)
- [ ] Test with real lead email addresses

---

## 🔧 Optional Improvements (Later)

- [ ] Add webhook authentication (WEBHOOK_SECRET)
- [ ] Set up error monitoring (Sentry)
- [ ] Add rate limiting per email/IP
- [ ] Create admin dashboard to view leads
- [ ] Add email templates for different classifications
- [ ] Set up automated backups of Supabase data

---

## 🆘 Troubleshooting

**Webhook not responding**:
- Check Vercel logs
- Verify environment variables are set
- Test health endpoint: `GET https://your-webhook.vercel.app/api/health`

**Emails not sending**:
- Check Resend dashboard for errors
- Verify RESEND_API_KEY is correct
- Check if domain is verified (for non-testing emails)

**Data not in Supabase**:
- Check webhook response for errors
- Verify SUPABASE_KEY is service_role key
- Check Supabase logs
- Verify find_or_create_company function exists

**OpenAI errors**:
- Check API key is valid
- Verify you have credits in OpenAI account
- Check rate limits

---

## 📝 Notes

**Why Vercel serverless is fine**:
- Webhooks are request/response - no need for always-on server
- Cold starts are < 1 second
- Automatically scales
- Free tier is generous
- Perfect for this use case

**When to use always-on (Railway/Render)**:
- WebSocket connections
- Background jobs/cron
- Real-time features
- Database connections pooling

This webhook doesn't need any of those - Vercel is perfect!
