# Technical Implementation Notes

## Project Overview

Building this business directory app was an interesting challenge, especially with the requirement to use Dio for networking even with local data. I decided to structure the app around Provider for state management since it strikes a good balance between simplicity and functionality, though I could have gone with BLoC for more complex scenarios.

The architecture follows a clean separation where the data layer handles all the business logic around fetching and caching, the Provider manages UI state, and the presentation layer focuses purely on displaying information. This made it much easier to handle the various states like loading, error, and empty data scenarios that users might encounter.

## Data Layer and Networking

One of the trickier aspects was working with the intentionally messy JSON keys like `biz_name`, `bss_location`, and `contct_no`. I handled this in the Business model's `fromJson` constructor where I normalize these into clean property names like `name`, `location`, and `contactNumber`. This keeps the rest of the codebase clean while dealing with the data inconsistencies at the source.

For the Dio requirement with local data, I took an approach that simulates real network behavior. The `BusinessService` loads JSON from assets but wraps it in Dio calls with artificial delays and proper response objects. This might seem like overkill for local data, but it means the code would work identically with a real API - just change the URL and remove the asset loading. The service also implements a 24-hour caching strategy using SharedPreferences, so the app works offline after the first load.

## State Management Approach

I went with Provider because it's straightforward and the team would likely be familiar with it. The `BusinessProvider` manages five distinct states: initial, loading, loaded, empty, and error. Each state triggers different UI responses, and I made sure to handle edge cases like network failures gracefully by falling back to cached data when possible.

The provider also includes retry logic and refresh functionality. Users can pull-to-refresh on the list screen or tap retry buttons when errors occur. This creates a smooth experience even when things go wrong.

## UI Components and Reusability

The `GenericCard` widget was probably the most interesting part to implement. Instead of creating a business-specific card, I built a generic one that takes any data type and a content builder function. This demonstrates composition over inheritance - you can reuse the same card structure for businesses, services, or any other model just by providing different content builders.

The two main screens handle all the standard states you'd expect in a production app. The list screen shows loading spinners, empty states with helpful messaging, error states with retry options, and the actual business cards when data loads successfully. The detail screen integrates with native phone and messaging apps using url_launcher, so users can actually call or message businesses directly.

## Technical Decisions and Trade-offs

I spent some time thinking about whether to use BLoC instead of Provider. BLoC would have given better separation of business logic and more testability, but for this scope, Provider felt more appropriate. The learning curve is gentler and the code is more approachable for a team that might be new to Flutter.

For persistence, SharedPreferences works well for simple caching, though for a larger app I might consider something like Hive or Isar for more complex data relationships. The 24-hour cache expiry feels reasonable for business data that doesn't change frequently.

The error handling strategy focuses on user experience over technical correctness. When the service fails, it attempts to show cached data rather than immediately throwing errors. This means users can still browse businesses they've seen before even when offline.

## Development Process

I structured the git commits to show a realistic development flow. Starting with just the basic scaffold and dependencies, then adding models and state management, followed by the networking layer, and finally the complete UI. Each commit represents a working state of the app, which is how I typically work on features.

The first commit just sets up the project structure with all necessary dependencies. The second adds the data models and Provider setup with some basic state management. The third integrates the Dio service and JSON data loading. The final commit brings everything together with the complete UI and native integrations.

## Areas for Improvement

If I had more time, I'd probably add pagination to the business list since loading hundreds of businesses at once could hurt performance. Image caching would be another nice addition if businesses had photos. For production use, integrating something like Crashlytics for error tracking and analytics for user behavior would be essential.

The current architecture could also benefit from a repository pattern to abstract the data sources better, and using get_it for dependency injection instead of relying on Provider's context-based approach. This would make testing easier and the code more modular.

Security-wise, if this were handling sensitive data, I'd want to use flutter_secure_storage instead of SharedPreferences and implement proper API key management. Internationalization would also be important for a real business directory that might serve multiple markets.
