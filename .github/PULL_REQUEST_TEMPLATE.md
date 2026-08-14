## What changed

<!-- Which page objects / tests / fixtures did you touch, and why? -->

## Checklist

- [ ] `npm run typecheck` passes
- [ ] `npm run lint` passes
- [ ] Every new/changed test is tagged with at least one of `@smoke @navigation @forms @functional @visual @responsive`
- [ ] No test submits a form, creates an account, or logs in (unless `auth.required: true`)
- [ ] No hardcoded URLs — tests use `baseURL` / `siteConfig`
- [ ] No assertions inside page objects (`src/pages/**`) — only in `tests/**`
- [ ] No `page.waitForTimeout()` — used `waitForSelector` / auto-waiting instead
- [ ] If visual baselines changed, screenshots were reviewed before committing (`npm run baseline`)
