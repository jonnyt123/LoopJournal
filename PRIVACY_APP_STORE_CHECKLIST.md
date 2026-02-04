# App Store Connect — App Privacy Selections Checklist

Use this checklist when filling the **App Privacy** section for LoopJournal in App Store Connect. It matches the verified Data Map and `privacy.html`.

**Principle:** Only categories that were **verified in the codebase** are included. If something was not present or could not be verified, it is not declared.

---

## 1. "Do you or your third-party partners collect data from this app?"

**Answer: Yes** (we collect user content locally; no third-party partners).

---

## 2. Data Used to Track You

**Answer: No data collected for tracking.**

- Do **not** add any data types under "Data Used to Track You."
- The app does not use data for tracking across apps or websites.
- No ATT, no IDFA, no third-party tracking.

---

## 3. Data Linked to You

**Answer: Yes.** Add **only** the following.

| Data Type (Apple label) | Category / sub-type | Purpose | Linked to user? | Used for tracking? |
|-------------------------|--------------------|---------|------------------|---------------------|
| **User Content**        | Other User Content (e.g. journal text, mood, photos in entries, voice, links) | App functionality | Yes (stored on device only) | No |

- **Collected:** Yes  
- **Purpose:** App functionality (display, store, delete journal entries)  
- **Linked to user:** Yes (device user)  
- **Used for tracking:** No  

Do **not** add: Identifiers, Contact Info, Browsing History, Search History, Health & Fitness, Financial Info, Location, Sensitive Info, or any other category not listed above.

---

## 4. Data Not Linked to You

**Answer: No.**

- Do **not** add any data types under "Data Not Linked to You."
- No analytics, no crash data, no diagnostics collected.

---

## 5. Third-Party Partners / Data Sharing

- **Do you share data with third parties for tracking?** No.  
- **Do you share data with data brokers?** No.  
- **Third-party SDKs that collect data:** None. Declare that no third-party partners collect data from the app.

---

## 6. Privacy Nutrition Labels (summary)

- **Data Used to Track You:** None.  
- **Data Linked to You:** User Content only (journal entries, mood, photos in entries, voice, links) — for app functionality, stored on device, not used for tracking.  
- **Data Not Linked to You:** None.

---

## 7. Optional Notes for App Review

- "All data is stored on-device only. No cloud sync, no analytics, no tracking."
- "Privacy policy: [URL to hosted privacy.html]"

Replace `[INSERT DATE]` and `[INSERT CONTACT EMAIL]` in `privacy.html` before hosting and submitting.
