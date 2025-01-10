
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Collect :isa(Stream::Operation::Terminal) {
    field $source      :param;
    field $accumulator :param;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, accumulator => $accumulator } if DEBUG;
    }

    method apply {
        LOG $self if DEBUG;
        while ($source->has_next) {
            TICK $self if DEBUG;
            my $next = $source->next;
            #say "Calling accumulator apply on $next";
            $accumulator->accept($next);
        }
        return $accumulator->result;
    }
}

