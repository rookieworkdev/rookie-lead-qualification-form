# Job Scraper Integration Tasks

## Completed

- [x] Indeed job scraper (types, config, AI prompt, scraper, processor, Supabase, routes, email digest)
- [x] GitHub Actions cron workflow
- [x] Fix Zod schema validation for Apify responses
- [x] Fix Supabase insert (remove non-existent `url` column)
- [x] Merge to main

## Database Changes (use Supabase MCP)

- [ ] Rename `company_description` → use `description` column only, then delete `company_description`
- [ ] Rename `job_ads` table → `jobs`
- [ ] Rename `job_ads_stats` table → `job_stats`
- [ ] Update all code references after table renames
- [ ] Remove `website_jobs` and `website_contacts` tables (after all tests pass)

## Code Quality & Testing

- [ ] Run all tests locally and live
- [ ] Add tests to `/tests` folder if needed
- [ ] Check Checklist for coding (reminder)
- [ ] Investigate `apify-client` --legacy-peer-deps issue (future compatibility?)

## Scraper Configuration

- [ ] Figure out keywords/exclusion_keywords input for different Apify scrapers
- [ ] Check/remove temporary item count filters from n8n flows
- [ ] Decide on fetch frequency (cron) and maxItems per scraper

## Future Scrapers

- [ ] LinkedIn job scraper (reuse Indeed patterns where applicable)
- [ ] Arbetsformedlingen job scraper
- [ ] Google Maps lead scraper

Note: Reuse logic from Indeed flow (system prompt, processor, etc.) but be careful not to over-merge - scrapers have different requirements.

## Deployment

- [ ] Add environment variables to deployment
- [ ] Add GitHub Secrets (`API_BASE_URL`, `SCRAPER_API_KEY`)
