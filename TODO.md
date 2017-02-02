App
---

 - Feature: edit work
 - Feature: Author portfolio (list of works)
 - Feature: unpublished/published works
 - Switch to webpack for frontend
 - Change wording on homepage to indicate closed alpha
 - Try make it not look shit
 - Integrate wow.js
 - Copy across remaining scss/images from old repo

Framework
---------

 > View Layer
   - Refactor/redesign implementation (see lib/page.rb)
   - Layout inheritance
   - Rename decorators -> presenters
   - Better decorator API
   - Probably switch to tilt gem
   - Invalidate all etags on new deployment

 > Controller/routing layer
   - Integrate Rack::Protection
   - Consider using Mustermann for route pattern matching
   - Consider replacing RSchema with dry-validation
   - Switch to enabled/disable lazy endpoint loading

 > Multithreading:
   - IoC container needs to be thread safe
   - Check that routing is all frozen (should be already)
   - Global db connection needs to be per-thread (maybe thread-local
     memoization in the container?)

 > Misc
   - Reorganise folder structure for everything
   - Try to 12-factor-app everything
   - Deployment strategy
   - Make bin/db_reset and bin/db_migrate or equivalent
   - Sequel migrations (probably ditch schema.rb, and just run all migrations)

