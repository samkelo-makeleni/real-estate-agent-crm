# BGN Real Estate App Feature Checklist

Status key:
- [x] Done
- [~] Partially done
- [ ] Not started

## Buyer Features

- [x] Favourites / saved properties
  - Buyers can save and filter favourite properties in browse/details.
- [ ] Property comparison
  - Compare price, beds, location, media count, and status.
- [~] Advanced filters
  - Done: keyword, property type, status, price range, favourites.
  - Next: sale/rent mode, bedrooms, bathrooms, exact area chips.
- [ ] Map view
  - Show properties and nearby schools, malls, transport, and hospitals.
- [~] Full media gallery
  - Done: media list and hero photo.
  - Next: full-screen gallery, video playback, floor plans, brochures.
- [ ] Share property link via WhatsApp
- [x] WhatsApp/call agent buttons on each property detail
- [~] Viewing request with preferred time slots
  - Done: buyer can book a viewing.
  - Next: multiple preferred slots and agent confirmation flow.
- [ ] Rental application progress tracker
- [ ] Document upload for rental applicants
  - ID, payslip, bank statements.
- [ ] Property alerts
  - Notify buyers when similar listings are added.
- [ ] Buyer profile
  - Budget, preferred areas, property needs.
- [ ] Recently viewed properties
- [ ] Mortgage/bond calculator
- [ ] Monthly rental affordability calculator
- [~] Enquiry status tracking
  - Done: lead status model exists.
  - Next: buyer-facing status timeline.

## Agent Features

- [ ] Lead pipeline board
  - New, Contacted, Viewing, Application, Closed.
- [~] Property status workflow
  - Done: available, pending, sold, rented.
  - Next: draft, live, archived.
- [x] Edit property screen with media management
- [ ] Drag-and-drop photo ordering
- [~] Video walkthrough upload and preview
  - Done: video upload path and media URL list.
  - Next: playable previews.
- [~] Appointment calendar with reminders
  - Done: appointment booking and list.
  - Next: calendar view and notifications.
- [ ] Client notes and follow-up tasks
- [ ] WhatsApp templates for quick replies
- [ ] Rental application dashboard
- [ ] Document checklist per applicant
- [ ] Owner/landlord contact management
- [ ] Property performance stats
  - Views, enquiries, applications.
- [ ] Agent notifications for new enquiries/viewing requests
- [ ] Team/admin roles
  - Principal, agent, assistant.
- [ ] Assign leads to agents
- [ ] Export leads/properties to CSV/PDF
- [ ] Commission tracker

## Shared Features

- [ ] Push notifications
- [ ] In-app chat between buyer and agent
- [ ] Audit trail
  - Who updated what and when.
- [ ] Search history
- [ ] Saved documents
- [~] Secure user roles
  - Done: user role model exists.
  - Next: real auth and guarded routes.
- [~] Supabase-backed real database/storage
  - Done: Supabase Auth, Postgres services, and Storage upload path are wired.
  - Next: realtime subscriptions, agency invitation flow, and production seed data.
- [ ] Analytics dashboard
- [ ] Offline-friendly property browsing
- [ ] Branded share cards for listings

## Best Next Build Order

1. Lead pipeline board for agents.
2. Full buyer media gallery with video playback.
3. Share property link via WhatsApp.
4. Recently viewed properties and search history.
5. Rental application progress tracker.
6. Document upload and applicant checklist.
7. Supabase realtime subscriptions for properties, leads, and appointments.
