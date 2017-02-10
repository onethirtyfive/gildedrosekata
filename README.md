
# Introduction

Implementation of the ["Gilded Rose" coding kata](http://iamnotmyself.com/2011/02/13/refactor-this-the-gilded-rose-kata/).

Based on the Ruby ready-to-go version found [here](https://github.com/jimweirich/gilded_rose_kata).

This document is a stream of consciousness list of thoughts accompanying each 
commit. The commits will be named in accordance with the sections below.


## commit: "kata: inherited code"

The complexity in lib/gilded\_rose.rb is out of control. The number of 
branch combinations the code can take makes it impossible to reason about 
as a whole.

Moreover the tests for conjured items do not pass.

It would be more interesting to think of the assessment of each item as its 
own process--and then share strategies where possible.

### In This Commit

1. Mark broken specs as pending, leaving as documentation. Fixing in current 
implementation is too painful.

### Mental TODO Roadmap

1. Organize legacy code as standard Ruby.
2. Remove garbage Given/When/Then rspec extension. Just use rspec.
3. No need to loop in `#update_quality`. Make this responsibility of calling 
code. (Loops are less composable than single operations.)
4. Identify inputs and outputs of "quality update" process. Kill mutation of 
`Item` struct.
5. Reassign namespace to terser `lib/gr`.
6. Implement each process.
7. Extract shared functionality into common code.


## commit: "kata: conventions, please"

First things first: a random function in the global namespace is garbage.

Let's make the code at least pretend to be Ruby.

### In This Commit

1. Introduce `GildedRose` namespace.
2. Move current crappy implementation to this namespace.
3. Update references in to this lib spec.
4. Remove `should` expectations in spec in favor of `expect`.

### Mental TODO Roadmap

1. No need to loop in `#update_quality`. Make this responsibility of calling 
code. (Loops are less composable than single operations.)
2. Identify inputs and outputs of "quality update" process. Kill mutation of 
`Item` struct.
3. Reassign namespace to terser `lib/gr`.
4. Implement each process.
5. Remove garbage Given/When/Then rspec extension. Just use rspec.
6. Extract shared functionality into common code.


## commit: "kata: out of the loop"

First things first: remove the loop from `#update_quality`.

Since the only calling code is our spec, we'll make the spec loop over items.

### In This Commit

1. `spec/lib/gilded_rose_spec.rb` calls `update_quality` with one item.
2. Delete some old specs testing "multiple items", as the functionality is 
covered already by the sufficiently general existing specs.

### Mental TODO Roadmap

1. Identify inputs and outputs of "quality update" process.
2. Kill mutation of `Item` struct. Return a new struct instead.
3. Reassign namespace to terser `lib/gr`.
4. Implement each process.
5. Remove garbage Given/When/Then rspec extension. Just use rspec.
6. Extract shared functionality into common code.


## commit: "kata: smoothing out wrinkles"

Looking at our function, two fields are conditionally changed on the provided
`Item`:

* `quality`
* `sell_in` (if item is not "Sulfuras, Hand of Ragnaros")

Since these are *ever* changed by our function, they *could* instead be the 
outputs. (Rather than changing them on our `Item`.) Since mutation causes 
unanticipated states, we prefer not doing it.

It appears our implementation needs `name`, `sell_in`, and `quantity` all to 
do its work, at least conditionally. (That's good enough--*ever* is the 
criterion.)

The way our implementation gets this information is by querying the provided 
`Item`. We don't have to do that, though. We could do this:

    def update_quality(item)
      name, sell_in, quality = *item
      ...

But then our function still has knowledge of `Item`. So let's go a step 
further and move those three fields to proper function arguments. This way, 
our function can stay happily oblivious to `Item`:

    def update_quality(name, sell_in, quality)
      ...

And our outputs (the things ever changed) can be `quality` and `sell_in`,
returned as an array. Since these two will change, we need to copy them
locally:

    def update_quality(name, sell_in, quality)
      new_sell_in = sell_in
      new_quality = quality
      ...

Since we're not mutating the provided `Item`, we must tweak our specs. Now, 
there is no `When`--we have a deterministic function that doesn't do anything 
dangerous. In fact, we no longer need `Item`. So let's delete it.

But now our function is named poorly. (It always was lol.) We're not 
"updating" anything. Let's call it `#appraise`.

### In This Commit

1. Update `#update_quality` to take the args it needs rather than a struct.
2. Cache local `sell_in` and `quality` vals, building new ones for return.
3. Stop mutating `Item`, realize we don't need it right now.
4. Rename `#update_quality` to `#appraise`.
5. Update specs to call the newly defined function.

### Mental TODO Roadmap

1. Discover the processes entangled in the method.
2. Implement each process. (Maybe multiple commits.)
3. Reassign namespace to terser `lib/gr`.
4. Extract shared functionality into common code.
5. Rework specs to reflect these processes.
6. Remove garbage Given/When/Then rspec extension. Just use rspec.


## commit: "kata: process of separation"

Now we need to think a bit harder. What is `#appraise` doing? Luckily, because 
we made it a deterministic function, we can tell everything we need to know by 
its *inputs* and *outputs*.

It takes a product's:

1. name
2. sell\_in
3. quality

And produces new:

1. sell\_in
2. quality

Name is invariant. OK. But we have two outputs. We know that, AT MOST, each of 
these outputs needs three pieces of data (the inputs). Let's dig into our 
implementation and see what each of them needs.

Deriving the "sell\_in" output *ever* requires:

1. name

Well, that's not surprising. We appraise "sell\_in" for non-legendary items.

Deriving the "quality" output *ever* requires:

1. name
2. sell\_in
2. quality

So, "quality" is way more state dependent than "sell\_in". Good to know.

Let's separate the two. Introducing `#adjust_sell_in`. It's what we do when 
appraising to square away the new "sell\_in" for this appraisal.

We should test it, too.

### In This Commit

1. Separate `adjust_sell_in` function.
2. Add specs.

### Mental TODO Roadmap

1. Discover the processes entangled in the method.
2. Implement each process. (Maybe multiple commits.)
3. Reassign namespace to terser `lib/gr`.
4. Extract shared functionality into common code.
5. Rework specs to reflect these processes.
6. Remove garbage Given/When/Then rspec extension. Just use rspec.


## commit: "kata: appraising the brie"

Let's go through `#appraise` for the "Aged Brie" product, removing one of the 
variables, and rewrite it as a separate function `#appraise_aged_brie`.

To accomplish this, we:

1. Duplicate the code in `#appraise`.
2. Delete huge chunks of conditional code which will never apply because 
`name` is invariant.
3. Notice that `new_sell_in` is never used before its definition, and so 
make it an argument to this function.
4. Combine a nested conditional into a new, top-level one.
5. Combine two conditionals into a nested one based on `new_quality < 50`.
6. Note that `adjusted_sell_in` is invariant, so remove it from the results 
(the calling code already knows the value).
7. Just cap quality at 50 explicitly, so we don't need branch logic.
7. Remove references to "Aged Brie" in original function.
8. Update "Aged Brie" specs to use this function instead.

### In This Commit

1. Code refactored as described above.
2. Specs for `#appraise_aged_brie`.


## commit: "kata: appraising the backstage passes"

Well, that went well. Let's do it for another product mentioned by name in 
`#appraise`.

Let's do the backstage passes. We'll follow the same process as before, making 
`#appraise_backstage_passes`.

### In This Commit

1. Code refactored as described above.
2. Specs for `#appraise_backstage_passes`.

### Mental TODO Roadmap

1. Discover the processes entangled in the method.
2. Implement each process. (Maybe multiple commits.)
3. Reassign namespace to terser `lib/gr`.
4. Extract shared functionality into common code.
5. Rework specs to reflect these processes.
6. Remove garbage Given/When/Then rspec extension. Just use rspec.


## commit: "kata: appraising what's left"

Our `#appraise` method is starting to look really anemic. Great!

There's just one more thing that sticks out: the legendary item.

Lather, rinse, repeat.

### In This Commit

1. Code refactored as described above.
2. Specs for `#appraise_backstage_passes`.
3. Simply remainder of `#appraise`, fix specs.

### Mental TODO Roadmap

1. Extract shared concerns.
2. Add processes for "conjured" items.
3. Remove garbage Given/When/Then rspec extension. Just use rspec.
4. Generalize code.
5. Re-namespace code into `lib/gr`.
6. Write basic CLI utilizing `lib/gr`.


## commit: "kata: pattern matching, plz"

We now have a collection of bespoke methods for dealing with different items.

Let's flex our brain a little bit to extract commonality of intent out from 
the code. Generally:

* The "sell\_in" attribute of an item with either stay the same or decrease.
* The "quality" attribute can decrease, increase, or assume a constant value.

For both "sell\_in" and "quality", changes are applied additively or by 
assignment.

We can further characterize the items thusly:

* normal - items whose quality depreciates over time.
* fleeting - items whose quality appreciates for a time, then vanishes.
* vintage - items whose quality appreciates indefinitely.
* enduring - items whose quality never changes.

Because of the arbitrariness of the rules for "sell\_in" and "quality", we 
should express effects as heuristics. In Ruby, this is best accomplished with
strategies, or subroutines. To keep things simple, we'll have one strategy for 
each characterization.

We will also reintroduce `Item`, since it's no longer an albatross (and is 
part of the project requirements).

### In This Commit

New `#tick` method which accepts an `Item` and:

1. Gets the next `sell_in` value appropriate for the `Item`.
2. Derives the action to take on an item's quality.
3. Applies that action.
4. Applies a ceiling to the quality, if applicable.
5. Applies a floor to the quality, if applicable.
6. Returns a brand new `Item` with the new information.

### Mental TODO Roadmap

1. Write basic CLI utilizing `lib/gilded_rose`.


## commit: "kata: cli"

Let's write a simple CLI with a starter database of our items in YAML.

### In This Commit

1. The CLI code.

And that's it. :)

