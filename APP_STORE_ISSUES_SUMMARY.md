# MyFA - Apple App Store Issues Summary

Quick reference for issues that must be fixed before App Store submission.

---

## 🔴 CRITICAL - Must Fix (5 issues)

| # | Issue | File | Status |
|---|-------|------|--------|
| 1 | **Localhost URL hardcoded** - Will fail on real devices | `App/App/AppConfig.swift:15` | ❌ Not Fixed |
| 2 | **Missing ATS exception** - Network requests will fail | `App/App/Info.plist` | ❌ Not Fixed |
| 3 | **Privacy descriptions insufficient** - Rejection risk | `App/App/Info.plist` | ❌ Not Fixed |
| 4 | **No trading disclaimers** - Simulated trades not marked | `App/ViewControllers/TradeConfirmationViewController.swift` | ❌ Not Fixed |
| 5 | **Missing App Store assets** - Cannot submit | N/A | ❌ Not Fixed |

---

## 🟡 WARNING - Should Fix (4 issues)

| # | Issue | File | Status |
|---|-------|------|--------|
| 6 | **Deep link security** - URL validation needed | `App/App/SceneDelegate.swift` | ⚠️ Review Needed |
| 7 | **Missing privacy manifest** - Future requirement | Need to create `PrivacyInfo.xcprivacy` | ⚠️ Review Needed |
| 8 | **Incomplete i18n** - Privacy strings not localized | `App/App/*/InfoPlist.strings` | ⚠️ Review Needed |
| 9 | **Memory leak potential** - Context providers | `App/Extensions/*ContextProvider.swift` | ⚠️ Review Needed |

---

## ℹ️ INFORMATIONAL - Recommendations (3 items)

| # | Item | Status |
|---|------|--------|
| 10 | Bundle ID review - Consider removing "chatkit" | ℹ️ Optional |
| 11 | Version number - Change from 0.1.0 to 1.0.0 | ℹ️ Optional |
| 12 | Performance testing - Test on real devices | ℹ️ Optional |

---

## ⚡ QUICK ACTIONS (Do These First)

```bash
# 1. Fix the localhost URL
# Edit App/App/AppConfig.swift and add production URL

# 2. Add demo disclaimer to app name
# Edit project.yml, set display name to "MyFA (Demo)"

# 3. Update privacy descriptions  
# Edit App/App/Info.plist - make descriptions detailed

# 4. Add ATS exception for dev builds
# Edit App/App/Info.plist - add NSAppTransportSecurity

# 5. Add simulation warning to trades
# Edit App/ViewControllers/TradeConfirmationViewController.swift
```

---

## 📱 Testing Checklist

Before submission, test:
- [ ] App launches on real device (iPhone)
- [ ] Server connection works (not localhost)
- [ ] All privacy permissions show proper descriptions
- [ ] Trading shows "SIMULATION" disclaimer
- [ ] Deep links work but are validated
- [ ] Language switching works
- [ ] No crashes or memory leaks
- [ ] Launch time < 2 seconds

---

## 📋 App Store Assets Needed

- [ ] Screenshots - iPhone 6.7" (3 required)
- [ ] Screenshots - iPhone 6.5" (3 required)  
- [ ] Screenshots - iPhone 5.5" (3 required)
- [ ] App Icon - 1024x1024px
- [ ] App Description - Emphasize "DEMO"
- [ ] Privacy Policy URL
- [ ] Support URL
- [ ] Keywords - Include "demo", "simulation"
- [ ] Category - Choose Education/Productivity (NOT Finance)

---

## 🎯 Priority Order

1. **CRITICAL Issue #1** - Fix localhost URL
2. **CRITICAL Issue #4** - Add demo disclaimers
3. **CRITICAL Issue #3** - Update privacy descriptions
4. **CRITICAL Issue #2** - Add ATS exception
5. **WARNING Issues** - Security and i18n
6. **CRITICAL Issue #5** - Prepare App Store assets
7. **INFORMATIONAL** - Polish and optimize

---

## 📞 Need Help?

See the full compliance document: `APPLE_APP_STORE_COMPLIANCE.md`

For each issue:
- ❌ Not Fixed = Must be addressed before submission
- ⚠️ Review Needed = Should be reviewed and likely fixed
- ℹ️ Optional = Nice to have, not required

---

**Last Updated:** November 24, 2025
