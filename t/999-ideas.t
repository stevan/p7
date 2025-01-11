
use v5.40;

package Functional {
    sub Function   ($t)     { return $t }
    sub BiFunction ($t, $u) { return $t }

    sub Consumer   ($t)     { return; }
    sub BiConsumer ($t, $u) { return; }

    sub Supplier { return true; }

    sub Predicate ($t) { return true; }
}

=pod

accepts params
    - has an argcheck, and it is with the correct arity

returns value
    - all return statements are followed by pushmark with 1 item

returns void
    - all return statements are followed by empty pushmark


=cut
