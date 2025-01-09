
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::concurrent ];

use org::p7::core::util qw[ Logger ];

class Flow::Operation::Map :isa(Flow::Operation) {
    field $f :param;

    method apply ($e) {
        LOG $self, { e => $e } if DEBUG;
        $self->submit( $f->apply( $e ) );
    }
}
