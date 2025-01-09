
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Operation::Every :isa(Stream::Operation::Node) {
    field $source :param :reader;
    field $stride :param :reader;
    field $event  :param :reader;

    field $seen = -1;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, stride => $stride, event => $event } if DEBUG;
    }

    method next {
        LOG $self if DEBUG;
        my $next = $source->next;
        if (++$seen >= $stride) {
            $event->accept($next);
            $seen = 0;
        }
        return $next;
    }

    method has_next { LOG $self if DEBUG; $source->has_next }
}
