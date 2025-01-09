
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Operation::ForEach :isa(Stream::Operation::Terminal) {
    field $source   :param;
    field $consumer :param;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, consumer => $consumer } if DEBUG;
    }

    method apply {
        LOG $self if DEBUG;

        while ($source->has_next) {
            TICK $self if DEBUG;
            $consumer->accept($source->next);
        }
        return;
    }
}
