Framework
---------

 - Layout inheritance
 - Consider renaming Endpoint => RequestHandler
 - Consider using Mustermann for route pattern matching
 - Consider replacing RSchema with dry-validation
 - Lazy endpoint lookup in the routing tree (so it doesn't eager load all endpoints)
 - Reorganise folder structure for everything
 - Refactor/redesign view layer (currently lib/page.rb)
 - Deployment strategy
 - Try to 12-factor-app everything
 - Integrate Rack::Protection
 - Make bin/db_reset and bin/db_migrate or equivalent
 - Multithreading:
   * IoC container needs to be thread safe
   * Check that routing is all frozen (should be already)
   * Global db connection needs to be per-thread (maybe thread-local memoization in the container?)


App
---

 - Feature: edit author bio
 - Feature: edit work
 - Feature: Author portfolio (list of works)
 - Feature: unpublished/published works
 - Change wording on homepage to indicate closed alpha
 - Try make it not look shit
 - Integrate wow.js
 - Copy across remaining scss/images from old repo
