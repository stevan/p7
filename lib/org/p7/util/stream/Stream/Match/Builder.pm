
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

use org::p7::util::function qw[
    Function
    Predicate
];

use Stream::Match;

class Stream::Match::Builder {
    field $match_root;
    field $current_match;

    method build_matcher (%opts) {
        $opts{on_match} = Function->new( f => $opts{on_match} )
            unless blessed $opts{on_match};

        $opts{predicate} = Predicate->new( f => $opts{predicate} )
            unless blessed $opts{predicate};

        return Stream::Match->new( %opts );
    }

    method build { LOG $self if DEBUG; $match_root }

    method starts_with (%opts) {
        LOG $self if DEBUG;
        die "Cannot call 'starts_with' twice"
            if defined $match_root;
        $match_root    = $self->build_matcher(%opts);
        $current_match = $match_root;
        $self;
    }

    method followed_by(%opts) {
        LOG $self if DEBUG;
        die "Cannot call 'followed_by' without calling 'starts_with' first"
            unless defined $current_match;
        $current_match->set_next( $self->build_matcher(%opts) );
        $current_match = $current_match->next;
        $self;
    }

    method matches_on (%opts) {
        LOG $self if DEBUG;
        die "Cannot call 'matches_on' without calling 'starts_with' first"
            unless defined $current_match;
        $current_match->set_next( $self->build_matcher(%opts) );
        $current_match = $current_match->next;
        $self;
    }
}
