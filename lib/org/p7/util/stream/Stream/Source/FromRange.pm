
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Source::FromRange :isa(Stream::Source) {
    field $start :param :reader;
    field $end   :param :reader;
    field $step  :param :reader = 1;

    field $current;
    ADJUST {
        $current = $start;
        LOG $self, 'ADJUST', { start => $start, end => $end, step => $step } if DEBUG;
    }

    method next {
        LOG $self if DEBUG;
        my $next = $current;
        $current += $step;
        return $next;
    }

    method has_next { LOG $self if DEBUG; $current <= $end }
}
