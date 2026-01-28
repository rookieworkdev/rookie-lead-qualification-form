# Quick Start Guide

Get the Rookie webhook running in 5 minutes.

## Prerequisites

- Node.js 18+ installed
- OpenAI API key
- Supabase project
- Gmail account

## Step 1: Install Dependencies

```bash
cd recruitment-webhook
npm install
```

## Step 2: Configure Environment

```bash
# Copy the example
cp .env.example .env

# Edit with your credentials
nano .env
```

Required variables:
```env
OPENAI_API_KEY=sk-proj-xxxxx
SUPABASE_KEY=eyJhbGciOiJxxxxx
GMAIL_USER=your-email@gmail.com
GMAIL_APP_PASSWORD=your-16-char-password
```

## Step 3: Set Up Supabase

Run this SQL in your Supabase SQL editor:

```sql
-- 1. Create tables (see README.md for full schemas)
-- 2. Create the stored procedure:

CREATE OR REPLACE FUNCTION find_or_create_company(
  p_name TEXT,
  p_domain TEXT,
  p_source TEXT DEFAULT 'website_form'
)
RETURNS UUID AS $$
DECLARE
  v_company_id UUID;
BEGIN
  IF p_domain IS NOT NULL THEN
    SELECT id INTO v_company_id FROM companies WHERE domain = p_domain LIMIT 1;
  END IF;
  
  IF v_company_id IS NULL THEN
    SELECT id INTO v_company_id FROM companies WHERE LOWER(name) = LOWER(p_name) LIMIT 1;
  END IF;
  
  IF v_company_id IS NULL THEN
    INSERT INTO companies (name, domain, source)
    VALUES (p_name, p_domain, p_source)
    RETURNING id INTO v_company_id;
  END IF;
  
  RETURN v_company_id;
END;
$$ LANGUAGE plpgsql;
```

## Step 4: Get Gmail App Password

1. Go to https://myaccount.google.com/security
2. Enable 2-Factor Authentication
3. Go to "App passwords"
4. Create password for "Mail"
5. Copy to `.env` as `GMAIL_APP_PASSWORD`

## Step 5: Start the Server

```bash
npm start
```

You should see:
```
{"level":"info","message":"Server started on port 3000",...}
```

## Step 6: Test It

```bash
curl -X POST http://localhost:3000/api/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "0701234567",
    "company": "Test AB",
    "industry": "technology",
    "service_type": "direktrekrytering",
    "message": "We need a software developer with 3 years experience in React",
    "subject": "General inquiry"
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "Valid lead processed successfully",
  "classification": "valid_lead",
  "lead_score": 75,
  "job_ad_title": "Software Developer",
  "processingTime": 8500
}
```

## Troubleshooting

### Port 3000 already in use
```bash
# Change PORT in .env
PORT=3001
```

### OpenAI errors
- Check your API key
- Verify you have credits
- Model is gpt-4o-mini

### Supabase errors
- Verify the stored procedure exists
- Check all tables are created
- Ensure SUPABASE_KEY has correct permissions

### Gmail errors
- Use App Password, not regular password
- Enable 2FA first
- Check the email address is correct

## Next Steps

1. **Deploy to production** (see README.md)
2. **Update your website form** to POST to this endpoint
3. **Set up monitoring** for production logs
4. **Add to your CI/CD pipeline**

## Need Help?

Check these files:
- `README.md` - Full documentation
- `IMPLEMENTATION.md` - Technical details
- Logs - Check console output for errors

## Success Checklist

- [ ] Server starts without errors
- [ ] Health check works: `curl http://localhost:3000/api/health`
- [ ] Test webhook responds with classification
- [ ] Email sends successfully (check inbox)
- [ ] Data appears in Supabase tables

You're ready to integrate! 🚀
