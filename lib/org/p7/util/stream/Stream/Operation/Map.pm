
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::stream ];

use org::p7::core::util qw[ Logging ];

class Stream::Operation::Map :isa(Stream::Operation::Node) {
    field $source :param;
    field $mapper :param;

    ADJUST {
        LOG $self, 'ADJUST', { source => $source, mapper => $mapper } if DEBUG;
    }

    method next     { LOG $self if DEBUG; $mapper->apply( $source->next ) }
    method has_next { LOG $self if DEBUG; $source->has_next }
}
