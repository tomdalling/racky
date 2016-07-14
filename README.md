Experimental web stuff. Shhhh. Top secret.

Aims
----

 - Aim for composability.
   Routers can dispatch to other routers.
   Controllers can all into other reusable controllers.
 - Aim for immutability.
   The majority of the app should be deep frozen at run time.
 - Exceptions are only for _unexpected_ bad situations, not for control flow.
   Expect all raised exceptions to cause a HTTP 500 response.

Web Layer
---------

 * Routing
   - Must be composable.
   - Captures params from the request path
   - Applies middleware while routing. This allows middleware to be enabled for a subset of endpoints.
   - Immutable. The entire routing tree can be deep frozen.
   - Authentication probably happens in this layer as middleware.
   - Will probably not provide a set of named routes.
     With all the dispatching and middleware, determining the exact URL of every endpoint is cumbersome.
     Named routes can be defined separately.

 * Middleware
   - Should this just be plain old Rack middleware?
   - Is it worth making specialised request/response data structures?

 * Controllers
   - Used to represent endpoints in the web application
   - Must be composable
   - HTTP logic only. No business logic.
   - Gathers params from the request and the routing captures.
     Performs _simple_ validation and coercion
     (e.g. the browser sent a string, but I'll convert it into a `Time` object)
   - Passes params into either a query or a command.
   - Uses the query/command return value to render a view (html, json, or whatever)
   - Probably has the same calling interface as routing objects.
     Will possibly be merged together with routing, a la Roda.

View Layer
----------

 - Should be purely functional, for the most part.
   View parameters go in, HTML/JSON/whatever comes out.
 - View logic probably goes into view models.
 - Still need to think about a caching strategy.
 - Called from controllers, _not_ from commands or queries.

Domain Layer
------------

 * Queries
   - Requests data from one or more datastores
   - Returns a single _immutable_ value
   - Can not fail, but return value can be empty or nil
   - Should never return data that the current user is unauthorized to view.
     Definitely requires authentication.
     Possibly shares authorization logic with commands, but maybe not.

 * Commands
   - Performs destructive updates of data stores
   - Return value indicates success or failure
   - Return value is immutable
   - Return value should probably provide a way to differentiate between different types of errors.
   - Failure return values should probably include error messages that can be displayed to the user.
     At the very least, they should include symbolic errors which can be translated into messages for the user.
   - Expects arguments to be _present_ (if required), and of the _correct type_
   - Validates input using domain logic (e.g. publish date must be in the past)

Design Areas To Explore
-----------------------

 - Make sure each layer has a decent testing strategy.
 - How does the controller response differ between controller validation failures
   (e.g. string can't be coerced into a date)
   and command validation failures
   (e.g. date is in the future, but must be in the past)?
 - Should commands and queries share authorization code?
 - Decide on a caching strategy for view rendering
