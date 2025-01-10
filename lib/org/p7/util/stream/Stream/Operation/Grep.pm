
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Grep :isa(Stream::Operation::Node) {
    field $source    :param;
    field $predicate :param;

    field $next;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, predicate => $predicate } if DEBUG;
    }

    method next { LOG $self if DEBUG; $next }

    method has_next {
        LOG $self if DEBUG;
        return false unless $source->has_next;
        $next = $source->next;
        until ($predicate->test($next)) {
            return false unless $source->has_next;
            $next = $source->next;
        }
        return true;
    }
}
