# Website Form Integration Guide

## Overview
Update your website form (on https://rookie-2-0.vercel.app/) to POST to this webhook.

---

## Step 1: Find Your Form Component

Look for your contact/recruitment form file in your website repo:
- Likely location: `src/components/ContactForm.tsx` or `src/app/contact/page.tsx`
- Or wherever your recruitment form is

---

## Step 2: Required Form Fields

Your form MUST collect these fields (map them to webhook format):

| Form Field Name | Webhook Field | Type | Required |
|----------------|---------------|------|----------|
| name | `name` | string | Yes |
| email | `email` | string | Yes |
| phone | `phone` | string | Yes |
| company | `company` | string | Yes |
| industry | `industry` | string | Yes |
| serviceType | `service_type` | string | Yes |
| message/description | `message` | string | Yes |
| subject | `subject` | string | No |

**Service Type Options**:
- `direktrekrytering`
- `rekrytering`
- `bemanning`
- Or whatever values you use

---

## Step 3: Update Form Submit Handler

### Current Code (Example - yours may differ):

```typescript
const handleSubmit = async (e: FormEvent) => {
  e.preventDefault();

  const formData = {
    name: nameField,
    email: emailField,
    phone: phoneField,
    company: companyField,
    industry: industryField,
    serviceType: serviceTypeField,
    message: messageField,
  };

  // Old way - maybe posting to your own API route
  const response = await fetch('/api/contact', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(formData)
  });
}
```

### New Code:

```typescript
const handleSubmit = async (e: FormEvent) => {
  e.preventDefault();
  setIsSubmitting(true);

  try {
    // Post to webhook
    const response = await fetch('https://your-webhook-project.vercel.app/api/webhook', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        name: nameField,
        email: emailField,
        phone: phoneField,
        company: companyField,
        industry: industryField,
        service_type: serviceTypeField, // Note: snake_case
        message: messageField,
        subject: 'Rekryteringsbehov', // or from a field
      })
    });

    if (response.ok) {
      const result = await response.json();
      console.log('✅ Lead processed:', result.classification);

      // Show success message to user
      setSuccessMessage('Tack! Vi har tagit emot din förfrågan.');

      // Optional: Different messages based on classification
      if (result.classification === 'valid_lead') {
        setSuccessMessage('Tack! Vi skickar snart ett mejl med förslag.');
      } else if (result.classification === 'likely_candidate') {
        setSuccessMessage('Tack! Vi har lagt till dig i vår kandidatdatabas.');
      }

      // Reset form
      resetForm();
    } else {
      throw new Error('Webhook failed');
    }
  } catch (error) {
    console.error('❌ Form submission error:', error);
    setErrorMessage('Något gick fel. Försök igen senare.');
  } finally {
    setIsSubmitting(false);
  }
}
```

---

## Step 4: Replace Webhook URL After Deployment

**During development (local testing)**:
```typescript
const WEBHOOK_URL = 'http://localhost:3000/api/webhook';
```

**After deploying to Vercel**:
```typescript
const WEBHOOK_URL = 'https://your-webhook-project.vercel.app/api/webhook';
```

**Best practice** - use environment variable:

1. In your website repo, create `.env.local`:
   ```
   NEXT_PUBLIC_WEBHOOK_URL=https://your-webhook-project.vercel.app/api/webhook
   ```

2. In your form code:
   ```typescript
   const WEBHOOK_URL = process.env.NEXT_PUBLIC_WEBHOOK_URL || 'http://localhost:3000/api/webhook';

   const response = await fetch(WEBHOOK_URL, {
     method: 'POST',
     // ...
   });
   ```

3. Add to Vercel (website project) environment variables:
   ```
   NEXT_PUBLIC_WEBHOOK_URL=https://your-webhook-project.vercel.app/api/webhook
   ```

---

## Step 5: Test the Integration

### Test locally first:

1. **Start webhook locally**:
   ```bash
   cd /Users/hanna/Desktop/recruitment-webhook
   npm run dev
   ```

2. **In your website**, use:
   ```typescript
   const WEBHOOK_URL = 'http://localhost:3000/api/webhook';
   ```

3. **Submit the form** and check:
   - Browser console for response
   - Webhook terminal for logs
   - Email at rookiework.dev@gmail.com

### Test after deployment:

1. Update `WEBHOOK_URL` to your Vercel deployment URL
2. Submit form from production website
3. Verify everything works

---

## Expected Webhook Response

### Success (valid_lead):
```json
{
  "success": true,
  "message": "Valid lead processed successfully",
  "classification": "valid_lead",
  "lead_score": 90,
  "job_ad_title": "Business Analyst till Autoliv AB",
  "processingTime": 15000
}
```

### Success (spam):
```json
{
  "success": true,
  "message": "Lead received but classified as spam (fast reject)",
  "classification": "spam",
  "processingTime": 1200
}
```

### Success (candidate):
```json
{
  "success": true,
  "message": "Lead classified as job seeker",
  "classification": "likely_candidate",
  "processingTime": 5000
}
```

### Error:
```json
{
  "success": false,
  "error": "Internal server error",
  "message": "Failed to send email: ...",
  "processingTime": 8000
}
```

---

## Troubleshooting

**CORS errors**:
- The webhook already has CORS enabled
- If still seeing errors, add your website domain to `.env`:
  ```
  ALLOWED_ORIGINS=https://rookie-2-0.vercel.app
  ```

**Form not submitting**:
- Check browser console for errors
- Verify webhook URL is correct
- Test webhook directly with curl first

**No email received**:
- Emails go to rookiework.dev@gmail.com until domain is verified
- Check Resend dashboard for delivery status

**Data not in Supabase**:
- Check webhook response for errors
- Look at webhook logs in Vercel

---

## Example: Complete Next.js Form Component

```typescript
'use client';

import { useState, FormEvent } from 'react';

const WEBHOOK_URL = process.env.NEXT_PUBLIC_WEBHOOK_URL || 'http://localhost:3000/api/webhook';

export default function RecruitmentForm() {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    company: '',
    industry: 'technology',
    serviceType: 'direktrekrytering',
    message: '',
  });

  const [isSubmitting, setIsSubmitting] = useState(false);
  const [successMessage, setSuccessMessage] = useState('');
  const [errorMessage, setErrorMessage] = useState('');

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    setSuccessMessage('');
    setErrorMessage('');

    try {
      const response = await fetch(WEBHOOK_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: formData.name,
          email: formData.email,
          phone: formData.phone,
          company: formData.company,
          industry: formData.industry,
          service_type: formData.serviceType,
          message: formData.message,
          subject: 'Rekryteringsbehov från webbplats',
        })
      });

      const result = await response.json();

      if (response.ok) {
        setSuccessMessage('Tack! Vi har tagit emot din förfrågan.');
        setFormData({
          name: '',
          email: '',
          phone: '',
          company: '',
          industry: 'technology',
          serviceType: 'direktrekrytering',
          message: '',
        });
      } else {
        throw new Error(result.message || 'Unknown error');
      }
    } catch (error) {
      console.error('Form submission error:', error);
      setErrorMessage('Något gick fel. Försök igen senare.');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {/* Form fields here */}

      {successMessage && (
        <div className="text-green-600">{successMessage}</div>
      )}

      {errorMessage && (
        <div className="text-red-600">{errorMessage}</div>
      )}

      <button
        type="submit"
        disabled={isSubmitting}
        className="btn-primary"
      >
        {isSubmitting ? 'Skickar...' : 'Skicka förfrågan'}
      </button>
    </form>
  );
}
```

---

## Next Steps

1. ✅ Find your form component in website repo
2. ✅ Update the fetch URL to point to webhook
3. ✅ Map form fields to webhook format (snake_case for service_type)
4. ✅ Test locally first (localhost:3000)
5. ✅ Deploy webhook to Vercel
6. ✅ Update webhook URL in form code
7. ✅ Deploy website changes
8. ✅ Test end-to-end from production website
