
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Reduce :isa(Stream::Operation::Terminal) {
    field $source  :param;
    field $initial :param;
    field $reducer :param;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, initial => $initial, reducer => $reducer } if DEBUG;
    }

    method apply {
        LOG $self if DEBUG;
        my $acc = $initial;
        while ($source->has_next) {
            TICK $self if DEBUG;
            $acc = $reducer->apply($source->next, $acc);
        }
        return $acc;
    }
}

