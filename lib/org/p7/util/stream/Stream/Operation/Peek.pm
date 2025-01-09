
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logger ];

class Stream::Operation::Peek :isa(Stream::Operation::Node) {
    field $source   :param;
    field $consumer :param;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, consumer => $consumer } if DEBUG;
    }

    method next {
        LOG $self if DEBUG;
        my $val = $source->next;
        $consumer->accept( $val );
        return $val;
    }

    method has_next { LOG $self if DEBUG; $source->has_next }
}
