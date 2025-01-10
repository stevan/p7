
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::When :isa(Stream::Operation::Node) {
    field $source    :param;
    field $consumer  :param;
    field $predicate :param;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, consumer => $consumer, predicate => $predicate } if DEBUG;
    }

    method next {
        LOG $self if DEBUG;
        my $val = $source->next;
        $consumer->accept( $val ) if $predicate->test( $val );
        return $val;
    }

    method has_next { LOG $self if DEBUG; $source->has_next }
}
