
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::TakeUntil :isa(Stream::Operation::Node) {
    field $source    :param;
    field $predicate :param;

    field $done = false;
    field $next = undef;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, predicate => $predicate } if DEBUG;
    }

    method next { LOG $self if DEBUG; $next }

    method has_next {
        LOG $self if DEBUG;
        return false if $done || !$source->has_next;
        $next = $source->next;
        $done = $predicate->test($next);
        return true;
    }
}
