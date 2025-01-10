
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Recurse :isa(Stream::Operation::Node) {
    field $source      :param :reader;
    field $can_recurse :param :reader;
    field $recurse     :param :reader;

    field $next;
    field @stack;

    ADJUST {
        push @stack => $source;

        LOG $self, 'ADJUST', { source => $source, can_recurse => $can_recurse, recurse => $recurse } if DEBUG;
    }

    method next { LOG $self if DEBUG; $next }

    method has_next {
        LOG $self if DEBUG;
        while (@stack) {
            if ($stack[-1]->has_next) {
                my $candidate = $stack[-1]->next;
                if ( $can_recurse->test( $candidate ) ) {
                    push @stack => $recurse->apply($candidate);
                }

                $next = $candidate;
                return true;
            }
            else {
                pop @stack;
                next;
            }
        }
        return false;
    }

}
