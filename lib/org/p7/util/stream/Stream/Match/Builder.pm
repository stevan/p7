
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::util::function qw[
    Function
    Predicate
];

use Stream::Match;

class Stream::Match::Builder {
    field $match_root;
    field $current_match;

    my sub build_match (%opts) {
        $opts{on_match} = Function->new( f => $opts{on_match} )
            unless blessed $opts{on_match};

        return Predicate->new( %opts ) if $opts{predicate};
        die "Cannot build match, no 'predicate' key present";
    }

    method build { $match_root }

    method starts_with (%opts) {
        die "Cannot call 'starts_with' twice"
            if defined $match_root;
        $match_root    = build_match(%opts);
        $current_match = $match_root;
        $self;
    }

    method followed_by(%opts) {
        die "Cannot call 'followed_by' without calling 'starts_with' first"
            unless defined $current_match;
        $current_match->set_next( build_match(%opts) );
        $current_match = $current_match->next;
        $self;
    }

    method matches_on (%opts) {
        die "Cannot call 'matches_on' without calling 'starts_with' first"
            unless defined $current_match;
        $current_match->set_next( build_match(%opts) );
        $current_match = $current_match->next;
        $self;
    }
}
