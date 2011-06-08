Resty
=====

What is Resty about?
--------------------

Resty is designed as a client for a particular type of discoverable REST API; one that returns JSON, and where that JSON
has particular keys which enable navigation of the data graph.

An example of a Resty response
-------------------------------

A GET made to:

    http://fishy.fish/fish/123

Might return the following JSON:

    {
      ':href': 'http://fishy.fish/fish/123',
      'tag_number': '3987349834',
      'name': 'Bob the Fish'
      'species' => {
        ':href' => 'http://species.fish/species/555'
      },
      'habitat' => {
        ':href' => 'http://fishy.fish/oceans/atlantic',
        'name' => 'Atlantic Ocean'
        'size' => 'quite large'
      }
    }

  - The ':href' indicates the URL this resource is available at.  In this case the URL is the one we requested, which is the
  normal case.

  - The 'species' key is a link to another resource.  If a GET is made to that URL, more information about that species will
  be available.  No other information about the species is available without doing that extra request.  It's also on a different
  domain, which doesn't matter to Resty at all.

  - The 'habitat' key is an example of a link containing the information you'll find at the link; this means that it's not
  necessary to do the extra request.  Generally this is done if it's always known that the related resources will be required.

Accessing the simple example with Resty
---------------------------------------

Given the above resource, you could execute the following code in IRB:

    ruby-1.9.2-p180 :001 > require 'resty'
     => true 
    ruby-1.9.2-p180 :002 > fish = Resty.href('http://fishy.fish/fish/123')
     => #<Resty:0xa5ba70c ...> 

At this stage, no requests will be made.  Once you start look at the properties of "fish", a request will be made to
GET the resource.

    ruby-1.9.2-p180 :003 > fish.name
     => "Bob the Fish"
    ruby-1.9.2-p180 :004 > fish.habitat
     => #<Resty:0xa590a24 ...> 
    ruby-1.9.2-p180 :005 > fish.habitat.name
     => "Atlantic Ocean"

Navigating the resource graph
-----------------------------

Looking at "habitat" didn't require extra requests (because the data for "habitat" was already populated in the first request),
but looking at "species" will require us to fetch that resource.  Let's assume that the species GET returns the following JSON:

    {
      ':href' => 'http://species.fish/species/555',
      'commonName' => 'Atlantic Salmon',
      'scientificName' => 'Salmo salar'
      'kingdom' => {
        ':href' => 'http://species.fish/kingdom/223'
      }
    }

Then the following will happen; notice that "common_name" is translated to "commonName".

    ruby-1.9.2-p180 :006 > fish.species.common_name
     => "Atlantic Salmon"

Now assume that the kingdom GET returns something sensible; we can do the following, chaining our method calls:

    ruby-1.9.2-p180 :007 > fish.species.kingdom.scientific_name
     => "Animalia"
