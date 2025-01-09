
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Operation::Take :isa(Stream::Operation::Node) {
    field $source :param;
    field $amount :param;

    field $taken = 0;
    field $next = undef;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, amount => $amount } if DEBUG;
    }

    method next { LOG $self if DEBUG; $next }

    method has_next {
        LOG $self if DEBUG;
        return false if $taken >= $amount;
        $next = $source->next;
        $taken++;
        return true;
    }
}
