
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Source::FromIterator :isa(Stream::Source) {
    field $seed     :param;
    field $next     :param;
    field $has_next :param;

    field $current;
    ADJUST {
        $current = $seed;
        LOG $self, 'ADJUST', { seed => $seed, next => $next, has_next => $has_next } if DEBUG;
    }

    method     next { LOG $self if DEBUG; $current = $next->apply($current) }
    method has_next {
        LOG $self if DEBUG;
        return true unless defined $has_next;
        return $has_next->test($current);
    }
}
