Songkick On Tour
================

This app was written at Music Hackday Stockholm. It consults your Dopplr account for your list of future trips. It uses these to check Songkick for gigs in the places you plan to visit.

Written using Sinatra + JRuby to be run on Google Appengine. The live site is at http://songkickontour.appspot.com

NOTES
=====

Until appengine-apis 0.0.13 is released, replace .gems/bundler_gems/jruby/1.8/gems/appengine-apis-0.0.12 with a checkout of appengine-apis trunk. This fixes the use of HTTPS.
